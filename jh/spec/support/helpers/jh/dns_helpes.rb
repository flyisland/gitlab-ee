# frozen_string_literal: true

module JH
  module DnsHelpers
    extend ::Gitlab::Utils::Override

    override :permit_local_dns!
    def permit_local_dns!
      super

      local_addresses = %r{
        \A
        ::1? |                                          # IPV6
        (127|10)\.10\.1\.\d{1,3} |                       # 127.10.1.x or 10.10.1.x local network on jh
        localhost
        \z
      }xi
      allow(Addrinfo).to receive(:getaddrinfo).with(local_addresses, anything, anything, :STREAM,
        any_args).and_call_original
    end
  end
end
