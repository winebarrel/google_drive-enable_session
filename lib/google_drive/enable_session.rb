require 'google/api_client'
require 'google/api_client/auth/file_storage'
require 'google_drive'

require 'google_drive/enable_session/version'

module GoogleDrive
  module EnableSession
    @credential_store_file = ::File.expand_path('~/google_drive-oauth2.json')
    SESSION_KEY = 'GoogleDrive::EnableSession::SESSION_KEY'

    class << self
      attr_accessor :credential_store_file

      def has_credential?
        ::File.exist?(credential_store_file)
      end

      def create_credential
        client_id = ''
        client_secret = ''

        while client_id.empty?
          print("CLIENT ID: ")
          client_id = $stdin.gets.chomp
        end

        while client_secret.empty?
          print("CLIENT SECRET: ")
          client_secret = $stdin.gets.chomp
          puts
        end

        file_storage do |storage|
          credential = Signet::OAuth2::Client.new(
            :client_id => client_id,
            :client_secret => client_secret,
            :refresh_token => ''
          )

          storage.write_credentials(credential)
        end
      end

      def file_storage
        storage = Google::APIClient::FileStorage.new(credential_store_file)
        yield(storage)
      end

      def with_auth(credential)
        session = Thread.current[SESSION_KEY]

        unless session
          if !credential.access_token
            fetch_access_token(credential)
          elsif credential.issued_at + credential.expires_in <= Time.new
            refresh(credential)
          end

          session = GoogleDrive.login_with_oauth(credential.access_token)
          Thread.current[SESSION_KEY] = session
        end

        yield(session)
      end

      def fetch_access_token(credential)
        credential.scope = %w(
          https://www.googleapis.com/auth/drive
          https://spreadsheets.google.com/feeds/
        ).join(' ')

        credential.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
        credential.grant_type = 'authorization_code'

        print("1. Open this page:\n%s\n\n" % credential.authorization_uri)
        print("2. Enter the authorization code shown in the page: ")
        credential.code = $stdin.gets.chomp

        credential.fetch_access_token!

        file_storage do |storage|
          storage.write_credentials(credential)
        end
      end

      def refresh(credential)
        credential.refresh!

        file_storage do |storage|
          storage.write_credentials(credential)
        end
      end
    end

    def enable_session
      this = GoogleDrive::EnableSession

      unless this.has_credential?
        this.create_credential
      end

      this.file_storage do |storage|
        credential = storage.load_credentials

        this.with_auth(credential) do |session|
          yield(session)
        end
      end
    end
    module_function :enable_session
  end
end
