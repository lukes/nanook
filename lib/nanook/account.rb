class Nanook

  # The <tt>Nanook::Account</tt> class contains methods to discover
  # publicly-available information about accounts on the nano network.
  #
  # Initialize this class through the convenient Nanook#account method:
  #
  #   nanook = Nanook.new
  #   account = nanook.account("xrb_...")
  #
  # Or compose the longhand way like this:
  #
  #   rpc_conn = Nanook::Rpc.new
  #   account = Nanook::Account.new(rpc_conn, "xrb_...")
  class Account

    def initialize(rpc, account)
      @rpc = rpc
      @account = account
    end

    # ==== Example response
    #   {
    #     "xrb_13bqhi1cdqq8yb9szneoc38qk899d58i5rcrgdk5mkdm86hekpoez3zxw5sd": "500000000000000000000000000000000000",
    #     "xrb_17k6ug685154an8gri9whhe5kb5z1mf5w6y39gokc1657sh95fegm8ht1zpn": "961647970820730000000000000000000000"
    #   }
    def delegators
      account_required!
      rpc(:delegators)[:delegators]
    end

    # Returns a boolean indicating if account is known. Note, the
    # reliability of the check depends on the node host having
    # synchronized itself with most of the blocks on the nano network,
    # otherwise you may get a false +false+. You can check if a node's
    # synchronization is particular low using Nanook::Node#sync_progress.
    #
    # ==== Example response
    #   true
    def exists?
      account_required!
      response = rpc(:validate_account_number)
      !response.empty? && response[:valid] == 1
    end

    # Returns an account's history of send and receive payments.
    # Amounts are in {raw}[https://nano.org/en/faq#what-are-nano-units-].
    #
    # ==== Arguments
    #
    # [+limit:+] Integer representing the maximum number of history
    #            items to return (default is 1000)
    #
    # ==== Example
    #
    #   account.history
    #   account.history(limit: 1)
    #
    # ==== Example response
    #   [
    #     {
    #      :type=>"send",
    #      :account=>"xrb_1kdc5u48j3hr5r7eof9iao47szqh81ndqgq5e5hrsn1g9a3sa4hkkcotn3uq",
    #      :amount=>200000000000000000000000000000,
    #      :hash=>"2C3C570EA8898443C0FD04A1C385A3E3A8C985AD792635FCDCEBB30ADF6A0570"
    #     },
    #     {
    #      :type=>"receive",
    #      :account=>"xrb_1niabkx3gbxit5j5yyqcpas71dkffggbr6zpd3heui8rpoocm5xqbdwq44oh",
    #      :amount=>7836413000000000000000000000000,
    #      :hash=>"16743E8FF52F454E876E68EDD11F23094DCB96795A3B7F32F74F88563ACDDB04"
    #     }
    #   ]
    def history(limit: 1000)
      account_required!
      rpc(:account_history, count: limit)[:history]
    end

    # Returns the public key belonging to an account.
    #
    # ==== Example response
    #   "3068BB1CA04525BB0E416C485FE6A67FD52540227D267CC8B6E8DA958A7FA039"
    def public_key
      account_required!
      rpc(:account_key)[:key]
    end

    # Returns a String of the representative account for the account.
    # Representatives are accounts which cast votes in the case of a
    # fork in the network.
    #
    # ==== Example response
    #
    #   "xrb_3pczxuorp48td8645bs3m6c3xotxd3idskrenmi65rbrga5zmkemzhwkaznh"
    def representative
      account_required!
      rpc(:account_representative)[:representative]
    end

    # Returns a Hash containing two keys:
    #
    # * +:balance+ - Amount of {raw}[https://nano.org/en/faq#what-are-nano-units-]
    #   in the account
    # * +:pending+ - Amount of {raw}[https://nano.org/en/faq#what-are-nano-units-]
    #   pending and not yet received by the account
    # ===== Example response
    #   {
    #    "balance": "10000",
    #    "pending": "10000"
    #   }
    def balance
      account_required!
      rpc(:account_balance)
    end

    # Returns a Hash containing the following information about an
    # account:
    #
    # * +:frontier+ - The latest block hash
    # * +:open_block+ - The first block in every account's blockchain. When this block was published the account was officially open
    # * +:representative_block+ - The block that named the representative for the account
    # * +:balance+ - Amount of {raw}[https://nano.org/en/faq#what-are-nano-units-]
    # * +:last_modified+ - Unix timestamp
    # * +:block_count+ - Number of blocks in the account's blockchain
    #
    # ==== Example response
    #   {
    #    :frontier=>"2C3C570EA8898443C0FD04A1C385A3E3A8C985AD792635FCDCEBB30ADF6A0570",
    #    :open_block=>"C82376314C387080A753871A32AD70F4168080C317C5E67356F0A62EB5F34FF9",
    #    :representative_block=>"C82376314C387080A753871A32AD70F4168080C317C5E67356F0A62EB5F34FF9",
    #    :balance=>11439597000000000000000000000000,
    #    :modified_timestamp=>1520500357,
    #    :block_count=>4
    #   }
    def info
      account_required!
      rpc(:account_info)
    end

    def ledger(limit: 1)
      account_required!
      rpc(:ledger, count: limit)[:accounts]
    end

    # Returns Array of block hashes
    # Or, with detailed: true, returns Hashes
    def pending(limit: 1000, detailed: false)
      account_required!

      args = { count: limit }
      args[:source] = true if detailed

      response = rpc(:pending, args)[:blocks]
      Nanook::Util.coerce_empty_string_to_type(response, (detailed ? Hash : Array))
    end

    # Returns the account's weight. Weight is determined by the
    # account's balance, and represents the voting weight that account
    # has on the network if it is a representative.
    #
    # ==== Example response
    #   1
    def weight
      account_required!
      rpc(:account_weight)[:weight]
    end

    private

    def rpc(action, params={})
      p = @account.nil? ? {} : { account: @account }
      @rpc.call(action, p.merge(params))
    end

    def account_required!
      if @account.nil?
        raise ArgumentError.new("Account must be present")
      end
    end

  end
end
