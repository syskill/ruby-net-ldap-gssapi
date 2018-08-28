require 'gssapi'
require 'net/ldap'

module Net
  class LDAP
    class GSSAPIError < Error; end

    class AuthAdapter
      class GSSAPI < Net::LDAP::AuthAdapter
        #--
        # Required parameters: :hostname
        # Optional parameters: :servicename
        #
        # Hostname must be a fully-qualified domain name.
        #
        # Service name defaults to "ldap", which is almost certainly what you want.
        #++
        def bind(auth)
          host, svc = [auth[:hostname], auth[:servicename] || "ldap"]
          raise Net::LDAP::BindingInformationInvalidError, "Invalid binding information" unless (host && svc)

          gsscli = ::GSSAPI::Simple.new(host, svc)
          context_established = nil
          challenge_response = proc do |challenge|
            if !context_established
              resp = gsscli.init_context(challenge)
              if resp.equal?(true)
                context_established = true
              elsif !resp || resp.empty?
                raise Net::LDAP::GSSAPIError, "Failed to establish GSSAPI security context"
              end
              resp
            else
              # After the security context has been established, the LDAP server will
              # offer to negotiate the security strength factor (SSF) and maximum
              # output size. We request an SSF of 0, i.e. no protection (integrity
              # and confidentiality protections aren't implemented here, yet) and no
              # size limit.
              #
              # N.b. your LDAP server may reject the bind request with an error
              # message like "protocol violation: client requested invalid layer."
              # That means that it is configured to require stronger protection.
              gsscli.wrap_message("\x01\xff\xff\xff".force_encoding("binary"), false)
            end
          end

          Net::LDAP::AuthAdapter::Sasl.new(@connection).
            bind(method: :sasl, mechanism: "GSSAPI",
                 initial_credential: gsscli.init_context,
                 challenge_response: challenge_response)
        end
      end
    end
  end
end

Net::LDAP::AuthAdapter.register(:gssapi, Net::LDAP::AuthAdapter::GSSAPI)
