class Nanook

  # The <tt>Nanook::Account</tt> class contains methods to discover
  # publicly-available information about accounts on the nano network.
  #
  # === Initializing
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

    # Returns a Hash containing the account's balance. Units are in
    # {raw}[https://nano.org/en/faq#what-are-nano-units-].
    #
    # [+:balance+] Account balance
    # [+:pending+] Amount pending and not yet received by the account
    #
    # ==== Arguments
    #
    # [+unit:+]   Symbol (default is +:nano+) Represents the unit that
    #             the balances will be returned in.
    #             Must be either +:nano+ or +:raw+. (Note: this method
    #             interprets +:nano+ as NANO, which is technically Mnano
    #             See {What are Nano's Units}[https://nano.org/en/faq#what-are-nano-units-])
    #
    # ===== Example response
    #   {
    #    "balance": "2",
    #    "pending": "1"
    #   }
    def balance(unit: Nanook::WalletAccount::DEFAULT_UNIT)
      account_required!

      unless Nanook::WalletAccount::UNITS.include?(unit)
        raise ArgumentError.new("Unsupported unit: #{unit}")
      end

      rpc(:account_balance).tap do |r|
        if unit == :nano
          r[:balance] = Nanook::Util.raw_to_NANO(r[:balance])
          r[:pending] = Nanook::Util.raw_to_NANO(r[:pending])
        end
      end
    end

    def id
      @block
    end

    # Returns a Hash containing the following information about an
    # account:
    #
    # [+:frontier+] The latest block hash
    # [+:open_block+] The first block in every account's blockchain. When this block was published the account was officially open
    # [+:representative_block+] The block that named the representative for the account
    # [+:balance+] Amount in {NANO}[https://nano.org/en/faq#what-are-nano-units-]
    # [+:last_modified+] Unix timestamp
    # [+:block_count+] Number of blocks in the account's blockchain
    #
    # When <tt>detailed: true</tt> is passed as an argument, this method
    # makes four additional calls to the RPC to return more information
    # about an account:
    #
    # [+:weight+] See #weight
    # [+:pending+] See #balance
    # [+:representative+] See #representative
    # [+:public_key+] See #public_key
    #
    # ==== Arguments
    #
    # [+detailed:+] Boolean (default is false). When +true+, four
    #               additional calls are made to the RPC to return more
    #               information
    #
    # ==== Example 1
    #
    #   account.info
    #
    # ==== Example 1 response
    #   {
    #     :balance=>11.439597000000001,
    #     :block_count=>4
    #     :frontier=>"2C3C570EA8898443C0FD04A1C385A3E3A8C985AD792635FCDCEBB30ADF6A0570",
    #     :modified_timestamp=>1520500357,
    #     :open_block=>"C82376314C387080A753871A32AD70F4168080C317C5E67356F0A62EB5F34FF9",
    #     :representative_block=>"C82376314C387080A753871A32AD70F4168080C317C5E67356F0A62EB5F34FF9",
    #   }
    #
    # ==== Example 2
    #
    #   account.info(detailed: true)
    #
    # ==== Example 2 response
    #   {
    #     :balance=>11.439597000000001,
    #     :block_count=>4,
    #     :frontier=>"2C3C570EA8898443C0FD04A1C385A3E3A8C985AD792635FCDCEBB30ADF6A0570",
    #     :modified_timestamp=>1520500357,
    #     :open_block=>"C82376314C387080A753871A32AD70F4168080C317C5E67356F0A62EB5F34FF9",
    #     :pending=>0,
    #     :public_key=>"A82C906460046D230D7D37C6663723DC3EFCECC4B3254EBF45294B66746F4FEF",
    #     :representative=>"xrb_3pczxuorp48td8645bs3m6c3xotxd3idskrenmi65rbrga5zmkemzhwkaznh",
    #     :representative_block=>"C82376314C387080A753871A32AD70F4168080C317C5E67356F0A62EB5F34FF9",
    #     :weight=>0
    #   }
    def info(detailed: false)
      account_required!

      response = rpc(:account_info)

      # Return the response if we don't need any more info
      return response unless detailed

      # Otherwise make additional calls
      response = response.merge({
        weight: weight,
        pending: balance[:pending],
        representative: representative,
        public_key: public_key
      })

      # Sort this new hash by keys
      Hash[response.sort].to_symbolized_hash
    end

    def inspect # :nodoc:
      "#{self.class.name}(id: \"#{id}\", object_id: \"#{"0x00%x" % (object_id << 1)}\")"
    end

    # Returns information about the given account as well as other
    # accounts up the ledger. The number of accounts returned is determined
    # by the <tt>limit:</tt> argument.
    #
    # The information in each Hash is the same as what the
    # #info(detailed: false) method returns.
    #
    # ==== Arguments
    #
    # [+limit:+] Number of accounts to return in the ledger (default is 1)
    #
    # ==== Example
    #
    #   ledger(limit: 2)
    #
    # ==== Example response
    #   {
    #    :xrb_3c3ek3k8135f6e8qtfy8eruk9q3yzmpebes7btzncccdest8ymzhjmnr196j=>{
    #      :frontier=>"2C3C570EA8898443C0FD04A1C385A3E3A8C985AD792635FCDCEBB30ADF6A0570",
    #      :open_block=>"C82376314C387080A753871A32AD70F4168080C317C5E67356F0A62EB5F34FF9",
    #      :representative_block=>"C82376314C387080A753871A32AD70F4168080C317C5E67356F0A62EB5F34FF9",
    #      :balance=>11439597000000000000000000000000,
    #      :modified_timestamp=>1520500357,
    #      :block_count=>4
    #    },
    #    :xrb_3c3ettq59kijuuad5fnaq35itc9schtr4r7r6rjhmwjbairowzq3wi5ap7h8=>{ ... }
    #  }
    def ledger(limit: 1)
      account_required!
      rpc(:ledger, count: limit)[:accounts]
    end


    # Returns information about pending block hashes that are waiting to
    # be received by the account.
    #
    # The default response is an Array of block hashes.
    # With the +detailed:+ argument, the method can return a more
    # complex Hash containing the amount in
    # {raw}[https://nano.org/en/faq#what-are-nano-units-] of the pending
    # block and the source account that sent it.
    #
    # ==== Arguments
    #
    # [+limit:+] Number of pending blocks to return (default is 1000)
    # [+detailed:+] Boolean to have this method return a more complex
    #               Hash of pending block information (default is +false+)
    #
    # ==== Example 1
    #
    #   pending
    #
    # ==== Example 1 response
    #
    #   ["000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]
    #
    # ==== Example 2
    #
    #   pending(detailed: true)
    #
    # ==== Example 2 response
    #
    #   {
    #     "000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"=>{
    #      "amount"=>"6000000000000000000000000000000",
    #      "source"=>"xrb_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr"
    #     }
    #   }
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
