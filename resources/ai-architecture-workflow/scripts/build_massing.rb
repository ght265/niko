# frozen_string_literal: true

require 'json'
require 'digest'

# Load from the SketchUp Ruby Console, then call build with an approved JSON file.
module AiArchitectureMassing
  def self.valid_number?(value)
    value.is_a?(Numeric) && value.to_f.finite?
  end

  def self.parse(raw)
    config = JSON.parse(raw)
    unless config.is_a?(Hash) && config['status'] == '已确认'
      raise ArgumentError, 'Provide a reviewed configuration with status 已确认.'
    end

    %w[input_revision coordinate_ref height_ref reviewed_by].each do |key|
      value = config[key]
      raise ArgumentError, "Missing #{key}." unless value.is_a?(String) && !value.strip.empty?
    end

    points = config['footprint_mm']
    valid_points = points.is_a?(Array) && points.length == 4 && points.all? do |point|
      point.is_a?(Array) && point.length == 2 && point.all? { |coordinate| valid_number?(coordinate) }
    end
    raise ArgumentError, 'Provide four finite XY pairs in local millimetres.' unless valid_points

    corners = points.map { |point| point.map(&:to_f) }
    axes = corners.transpose.map(&:uniq)
    edges_follow_axes = corners.each_with_index.all? do |(x, y), index|
      next_x, next_y = corners[(index + 1) % corners.length]
      (x == next_x) ^ (y == next_y)
    end
    unless axes.all? { |axis| axis.length == 2 } && corners.uniq.length == 4 && edges_follow_axes
      raise ArgumentError, 'Footprint must be an axis-aligned rectangle in perimeter order.'
    end

    base_z = config['base_z_mm']
    height = config['height_mm']
    unless valid_number?(base_z) && valid_number?(height) && height.positive? &&
           (base_z.to_f + height.to_f).finite?
      raise ArgumentError, 'Provide a finite base elevation and positive height.'
    end

    config
  end

  def self.build(config_path)
    raw = File.read(config_path, encoding: 'UTF-8')
    config = parse(raw)
    fingerprint = Digest::SHA256.hexdigest(raw)
    model = Sketchup.active_model
    raise 'Exit group editing before running.' if model.active_path

    existing = model.entities.grep(Sketchup::Group).any? do |group|
      group.get_attribute('ai_architecture_massing', 'input_sha256')
    end
    raise 'Use a fresh working copy or undo the previous build.' if existing

    points = config['footprint_mm'].map do |x, y|
      Geom::Point3d.new(x.mm, y.mm, config['base_z_mm'].mm)
    end
    raise 'Could not start model operation.' unless model.start_operation('Build reviewed massing', true)

    begin
      group = model.entities.add_group
      face = group.entities.add_face(points)
      raise 'SketchUp could not create the base face.' unless face

      face.reverse! if face.normal.z.positive?
      face.pushpull(-config['height_mm'].mm)
      raise 'Generated group is not a closed solid.' unless group.manifold?

      group.name = "AI Massing - #{config.fetch('input_revision')}"
      group.set_attribute('ai_architecture_massing', 'input_sha256', fingerprint)
      %w[input_revision coordinate_ref height_ref reviewed_by].each do |key|
        group.set_attribute('ai_architecture_massing', key, config.fetch(key))
      end
      model.commit_operation
    rescue StandardError
      model.abort_operation
      raise
    end

    group
  end
end
