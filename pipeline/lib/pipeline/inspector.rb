require 'fileutils'

module Pipeline
  # Class for handling inspector tests
  class Inspector
    def initialize(params = {})
      @params = params
      @params[:region] = ENV['AWS_REGION']
      @params[:region] ||= 'us-east-1'

      setup_inspector
      run_inspector
      cleanup_inspector
    end

    def setup_inspector
      puts("\n\n\n=== AWS Inspector ===\n\n")

      # Ensure a clean slate
      cleanup_inspector

      # Clone the repo
      system 'git', 'clone', 'https://github.com/stelligent/inspector-status'
    end

    def run_inspector
      ENV['AWS_REGION'] ||= 'us-east-1'

      Dir.chdir('inspector-status') do
        system 'bundle', 'install'
        system './inspector.rb', '--target-tags', 'InspectorAuditable:true',
               '--aws-name-prefix', 'AWS-DEVSECOPS-WORKSHOP',
               '--failure-metrics', 'numeric_severity:9',
               '--rules-to-run', 'SEC,COM,RUN,CIS',
               '--asset-duration', '300'
      end
    rescue RuntimeError => errors
      cleanup_inspector
      raise errors
    end

    def cleanup_inspector
      FileUtils.rm_rf('inspector-status')
    end
  end
end
