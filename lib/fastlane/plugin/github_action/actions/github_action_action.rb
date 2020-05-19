require 'fastlane/action'
require_relative '../helper/github_actions_helper'

module Fastlane
  module Actions
    class GithubActionAction < Action
      def self.run(params)
        UI.message("The github_actions plugin is working!")

        self.check_for_setup_ci_in_fastfile

        additional_secrets = self.generate_deploy_key(params)
        secret_names = self.post_secrets(params, additional_secrets)
        self.generate_workflow_template(params, secret_names)
      end

      def self.match_deploy_key
        "MATCH_DEPLOY_KEY"  
      end

      def self.deploy_key_title
        "Match Deploy Key (created by fastalne-plugin-github_actions)"
      end
      
      def self.check_for_setup_ci_in_fastfile
        fastfiles = Dir.glob("./*/Fastfile").map do |path|
          File.absolute_path(path)
        end
       
        fastfiles.each do |path|
          content = File.read(path)

          if !content.include?("setup_ci")
            UI.confirm("`setup_ci` is not detected for '#{path}'. Do you still want to continue on?")
          end
        end

      end

      def self.generate_workflow_template(params, secret_names)
        require 'fastlane/erb_template_helper'
        include ERB::Util
          
        spaces = " " * 10
          
        #
        # Clone test secrets and commands
        #
        clone_test_secrets = [
          'GIT_SSH_COMMAND: "ssh -o StrictHostKeyChecking=no"',
          "#{match_deploy_key}: ${{ secrets.#{match_deploy_key} }}"
        ].map do |secret|
          "#{spaces}#{secret}"
        end.join("\n")

        clone_test_commands = [
          'eval "$(ssh-agent -s)"',
          "ssh-add - <<< \"${#{match_deploy_key}}\"",
          "git clone git@github.com:#{params[:match_org]}/#{params[:match_repo]}.git",
          "ls #{params[:match_repo]}"
        ].map do |command|
          "#{spaces}#{command}"
        end.join("\n")

        #
        # Secrets and commands
        #
        secrets = secret_names.map do |secret_name|
          "#{secret_name}: ${{ secrets.#{secret_name}  }}"
        end
        secrets << 'GIT_SSH_COMMAND: "ssh -o StrictHostKeyChecking=no"'
        secrets << 'MATCH_READONLY: true'

        secrets = secrets.map do |secret|
          "#{spaces}#{secret}"
        end.join("\n")

        commands = [
          'eval "$(ssh-agent -s)"',
          "ssh-add - <<< \"${#{match_deploy_key}}\"",
          'bundle exec fastlane test'
        ].map do |command|
          "#{spaces}#{command}"
        end.join("\n")


        workflow_template = Helper::GithubActionHelper.load("workflow_template")
        workflow_render = Helper::GithubActionHelper.render(workflow_template, {
          clone_test_secrets: clone_test_secrets,
          clone_test_commands: clone_test_commands,
          secrets: secrets,
          commands: commands
        })

        workflows_dir = File.absolute_path(".github/workflows")

        FileUtils.mkdir_p(workflows_dir)
        File.write(File.join(workflows_dir, 'fastlane.yml'), workflow_render)
      end

      def self.generate_deploy_key(params)
        get_deploy_keys_resp = self.match_repo_get(params, "/keys")

        sleep(1)

        deploy_keys = get_deploy_keys_resp[:json] || []
        deploy_keys.each do |deploy_key|
          if deploy_key["title"] == deploy_key_title
            if UI.confirm("Deploy Key for the match repo already exists... Delete it?")
              self.match_repo_delete(params, "/keys/#{deploy_key["id"]}")
              UI.message("Deleted existing Deploy Key")
              sleep(1)
            else
              return {}
            end
          end
        end

        require 'sshkey'
        k = SSHKey.generate()

        body = {
          title: deploy_key_title,
          key: k.ssh_public_key,
          read_only: true
        }
        post_deploy_key_resp = self.match_repo_post(params, "/keys", body)
        UI.message("Created Deploy Key")
        
        sleep(3)
       
        secrets = {}
        secrets[match_deploy_key] = k.private_key  
        return secrets
      end

      def self.post_secrets(params, additional_secrets)
        public_key_resp = self.repo_get(params, "/actions/secrets/public-key")
        key_id = public_key_resp[:json]["key_id"]
        key64 = public_key_resp[:json]["key"]

        secrets = self.parse_dotenvs(params)
        secrets = secrets.merge(additional_secrets || {})

        encrypted_secrets = {}
        secrets.each do |k,v|
          encrypted_value = self.encrypt_secret(key64, v)
          encrypted_secrets[k] = encrypted_value
        end

        existing_secrets_resp = self.repo_get(params, "/actions/secrets")
        existing_secret_names = existing_secrets_resp[:json]["secrets"].map do |secret|
          secret["name"].to_s
        end

        encrypted_secrets.reject! do |k,v|
          if existing_secret_names.include?(k.to_s)
            !UI.confirm("Overwrite #{k}?")
          end
        end

        encrypted_secrets.each do |k,v|
          body = {
            key_id: key_id,
            encrypted_value: v
          }
          self.repo_put(params, "/actions/secrets/#{k}", body)
          UI.message("Saving secret #{k}")
        end

        return secrets.keys
      end

      def self.parse_dotenvs(params)
        dotenv_paths = (params[:dotenv_paths] || [])

        if dotenv_paths.empty?
          UI.message "No dotenv paths to parse"
          return {}
        end

        require "dotenv"
        return Dotenv.parse(*dotenv_paths)
      end

      def self.repo_get(params, path)
        return other_action.github_api(
          server_url: params[:server_url],
          api_token: params[:api_token],
          http_method: "GET",
          path: "/repos/#{params[:org]}/#{params[:repo]}#{path}",
          body: {},
        )
      end

      def self.repo_put(params, path, body)
        return other_action.github_api(
          server_url: params[:server_url],
          api_token: params[:api_token],
          http_method: "PUT",
          path: "/repos/#{params[:org]}/#{params[:repo]}#{path}",
          body: body,
        )
      end

      def self.match_repo_get(params, path)
        return other_action.github_api(
          server_url: params[:server_url],
          api_token: params[:api_token],
          http_method: "GET",
          path: "/repos/#{params[:match_org]}/#{params[:match_repo]}#{path}",
          body: {},
        )
      end

      def self.match_repo_post(params, path, body)
        return other_action.github_api(
          server_url: params[:server_url],
          api_token: params[:api_token],
          http_method: "POST",
          path: "/repos/#{params[:match_org]}/#{params[:match_repo]}#{path}",
          body: body,
        )
      end

      def self.match_repo_delete(params, path)
        return other_action.github_api(
          server_url: params[:server_url],
          api_token: params[:api_token],
          http_method: "DELETE",
          path: "/repos/#{params[:match_org]}/#{params[:match_repo]}#{path}",
          body: {},
        )
      end

      def self.encrypt_secret(key64, secret)
        require "rbnacl"
        require "base64"

        key = Base64.decode64(key64)
        public_key = RbNaCl::PublicKey.new(key)

        box = RbNaCl::Boxes::Sealed.from_public_key(public_key)
        encrypted_secret = box.encrypt(secret)

        return Base64.strict_encode64(encrypted_secret)
      end

      def self.description
        "Helper to setup GitHub actions for fastlane and match"
      end

      def self.authors
        ["josdholtz"]
      end

      def self.details
        "Helper to setup GitHub actions for fastlane and match"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :server_url,
                                       env_name: "FL_GITHUB_API_SERVER_URL",
                                       description: "The server url. e.g. 'https://your.internal.github.host/api/v3' (Default: 'https://api.github.com')",
                                       default_value: "https://api.github.com",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please include the protocol in the server url, e.g. https://your.github.server/api/v3") unless value.include?("//")
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_GITHUB_API_TOKEN",
                                       description: "Personal API Token for GitHub - generate one at https://github.com/settings/tokens",
                                       sensitive: true,
                                       code_gen_sensitive: true,
                                       is_string: true,
                                       default_value: ENV["GITHUB_API_TOKEN"],
                                       default_value_dynamic: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :org,
                                       env_name: "FL_GITHUB_ACTIONS_ORG",
                                       description: "Name of organization of the repository for GitHub Actions"),
          FastlaneCore::ConfigItem.new(key: :repo,
                                       env_name: "FL_GITHUB_ACTIONS_REPO",
                                       description: "Name of repository for GitHub Actions"),
          FastlaneCore::ConfigItem.new(key: :match_org,
                                       env_name: "FL_GITHUB_ACTIONS_MATCH_ORG",
                                       description: "Name of organization of the match repository",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :match_repo,
                                       env_name: "FL_GITHUB_ACTIONS_MATCH_REPO",
                                       description: "Name of match repository",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :dotenv_paths,
                                       env_name: "FL_GITHUB_ACTINOS_DOTENV_PATHS",
                                       description: "Paths of .env files to parse",
                                       optional: true,
                                       type: Array,
                                       verify_block: proc do |values|
                                         values.each do |value|
                                           UI.user_error!("Path #{value} doesn't exist") unless File.exist?(value)
                                         end 
                                       end),
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
