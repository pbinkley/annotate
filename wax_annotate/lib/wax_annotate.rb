require 'wax_annotate/version'

# top level comment todo
module WaxAnnotate
  class Error < StandardError; end

  #
  #
  def self.create_annotation_list(canvas)
    canvas_dir = canvas.gsub(/.json$/, '')
    canvas_name = File.basename(canvas_dir)
    list_path = "#{canvas_dir}/list.json"
    return if File.exist?(list_path)

    puts "Creating #{list_path}\n".cyan

    list_content = <<~HEREDOC
      ---
      layout: none
      canvas: '#{canvas_name}'
      ---
      {% assign anno_name = page.canvas | append: '-resources' %}
      {% assign annotations = site.pages | where: 'label', anno_name | first %}
      {
        "@context": "http://iiif.io/api/presentation/2/context.json",
        "@id": "{{ '#{list_path}' | absolute_url }}",
        "@type": "sc:AnnotationList",
        "resources": {{ annotations.content }}
      }
    HEREDOC

    FileUtils.mkdir_p(canvas_dir)
    File.open(list_path, 'w') { |f| f.write(list_content) }
  end

  #
  #
  def self.parse_annotations(canvas)
    JSON.parse(File.read(canvas))
  rescue StandardError => e
    raise "Cannot parse annotation JSON for file #{canvas}.\n#{e}".magenta
  end


  #
  #
  def self.store_annotations(canvas)
    annotations = WaxAnnotate.parse_annotations(canvas)
    name = File.basename(canvas, '.json')
    annotation_path = canvas.gsub("#{name}.json", "#{name}/#{name}.json")

    if File.exist?(annotation_path)
      old_annotations = JSON.parse(remove_yaml(File.read(annotation_path)))
      annotations = annotations.concat old_annotations
    end

    content = <<~HEREDOC
      ---
      layout: none
      label: #{name}-resources
      ---
      #{JSON.pretty_generate(annotations)}
    HEREDOC

    puts "Adding annotations to #{annotation_path}".cyan
    File.open(annotation_path, 'w+') { |f| f.write(content) }
  end

  #
  #
  def self.remove_yaml(string)
    string.gsub(/\A---(.|\n)*?---/, '')
  end

  #
  #
  def self.parse_manifest(manifest)
    text = File.read("iiif/#{manifest}/clean-manifest.json")
    text = remove_yaml(text)
    JSON.parse(text)
  end

  #
  #
  def self.update_manifest(item)
    stored_canvases = Dir["#{item}/*/"].map do |c|
      File.basename(c, '.*')
    end

    return if stored_canvases.empty?

    puts "Adding annotations from #{stored_canvases} to manifest copy.".cyan

    manifest_json = parse_manifest(item)
    canvases = manifest_json['sequences'][0]['canvases'].select do |c|
      stored_canvases.include? c['@id'].split('/')[-1]
    end

    canvases.each do |canvas|
      annotation = {}
      id = canvas['@id'].split('/')[-1]
      annotation['@id'] = "{{ '/annotations/#{manifest}/#{id}/list.json' | absolute_url }}"
      annotation['@type'] = 'sc:AnnotationList'
      canvas['otherContent'] = [annotation]
    end

    content = <<~HEREDOC
      ---
      layout: none
      ---
      #{JSON.pretty_generate(manifest_json)}
    HEREDOC

    File.open("iiif/#{manifest}/manifest.json", 'w+') { |f| f.write(content) }
  end
end
