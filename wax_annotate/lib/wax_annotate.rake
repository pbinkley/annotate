require 'colorize'
require 'fileutils'
require 'json'

require_relative 'wax_annotate'

namespace :wax do
  namespace :annotate do
    desc 'store local iiif annotations and add them to manifest'
    task :iiif do
      Dir['annotations/*'].each do |item|
        Dir["#{item}/*.json"].sort!.each do |canvas|
          WaxAnnotate.create_annotation_list(canvas)
          WaxAnnotate.store_annotations(canvas)
          # File.delete(canvas)
        end
        WaxAnnotate.update_manifest(item)
      end
    end
  end
end
