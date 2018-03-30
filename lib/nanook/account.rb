class Nanook

  # The <tt>Nanook::Account</tt> class contains methods to discover
  # publicly-available information about accounts on the nano network.
  #
  # === Initializing
  #
  # Initialize this class through the convenient {Nanook#account} method:
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

    # Returns information about this account's delegators.
    # === Example response:
    #   {
    #     :xrb_13bqhi1cdqq8yb9szneoc38qk899d58i5rcrgdk5mkdm86hekpoez3zxw5sd=>500000000000000000000000000000000000,
    #     :xrb_17k6ug685154an8gri9whhe5kb5z1mf5w6y39gokc1657sh95fegm8ht1zpn=>961647970820730000000000000000000000
    #   }
    #
    # @return [Hash{Symbol=>String}] Delegators
    def delegators
      rpc(:delegators)[:delegators]
    end

    # Returns a boolean indicating if the account exists.
    #
    # Existence is determined by if the account has an _open_ block.
    # An _open_ block is a special kind of block that gets published when
    # an account receives a payment for the first time.
    #
    # The reliability of this check depends on the node host having
    # synchronized itself with most of the blocks on the nano network,
    # otherwise you may get +false+ when the account does exist.
    # You can check if a node's  synchronization is particular low
    # using {Nanook::Node#sync_progress}.
    #
    # @return [Boolean] Indicates if this account exists in the nano network
    def exists?
      response = rpc(:account_info)
      !response.empty? && !response[:open_block].nil?
    end

    # Returns an account's history of send and receive payments.
    #
    # ==== Example:
    #
    #   account.history
    #   account.history(limit: 1)
    #
    # ==== Example response:
    #   [
    #     {
    #      :type=>"send",
    #      :account=>"xrb_1kdc5u48j3hr5r7eof9iao47szqh81ndqgq5e5hrsn1g9a3sa4hkkcotn3uq",
    #      :amount=>2,
    #      :hash=>"2C3C570EA8898443C0FD04A1C385A3E3A8C985AD792635FCDCEBB30ADF6A0570"
    #     }
    #   ]
    # ==== Example:
    #
    #   account.history
    #   account.history(unit: :raw)
    #
    # ==== Example response:
    #   [
    #     {
    #      :type=>"send",
    #      :account=>"xrb_1kdc5u48j3hr5r7eof9iao47szqh81ndqgq5e5hrsn1g9a3sa4hkkcotn3uq",
    #      :amount=>2000000000000000000000000000000,
    #      :hash=>"2C3C570EA8898443C0FD04A1C385A3E3A8C985AD792635FCDCEBB30ADF6A0570"
    #     }
    #   ]
    #
    # @param limit [Integer] maximum number of history items to return
    # @param unit (see #balance)
    # @return [Array<Hash{Symbol=>String}>] the history of send and receive payments for this account
    def history(limit: 1000, unit: Nanook.default_unit)
      unless Nanook::UNITS.include?(unit)
        raise ArgumentError.new("Unsupported unit: #{unit}")
      end

      response = rpc(:account_history, count: limit)[:history]

      if unit == :raw
        return response
      end

      response.map! do |history|
        history[:amount] = Nanook::Util.raw_to_NANO(history[:amount])
        history
      end
    end

    # @return [Time] last modified time of the account in UTC time zone.
    def last_modified_at
      response = rpc(:account_info)
      Time.at(response[:modified_timestamp])
    end

    # Returns the public key belonging to an account.
    #
    # ==== Example response:
    #   "3068BB1CA04525BB0E416C485FE6A67FD52540227D267CC8B6E8DA958A7FA039"
    #
    # @return [String] public key of this account
    def public_key
      rpc(:account_key)[:key]
    end

    # Returns the representative account for the account.
    # Representatives are accounts which cast votes in the case of a
    # fork in the network.
    #
    # ==== Example response
    #
    #   "xrb_3pczxuorp48td8645bs3m6c3xotxd3idskrenmi65rbrga5zmkemzhwkaznh"
    #
    # @return [String] Representative account of this account
    def representative
      rpc(:account_representative)[:representative]
    end

    # Returns a Hash containing the account's balance.
    #
    # ==== Example:
    #
    #   account.balance
    #
    #   # =>
    #   # {
    #   #   balance=>2,   # Account balance
    #   #   pending=>1.1  # Amount pending and not yet received by the account
    #   # }
    #
    # ==== Example balance returned in raw:
    #
    #   account.balance(unit: :raw)
    #
    #   # =>
    #   # {
    #   #   balance: 2000000000000000000000000000000,
    #   #   pending: 1100000000000000000000000000000
    #   # }
    #
    # @param unit [Symbol] default is {Nanook.default_unit}.
    #   Must be one of {Nanook::UNITS}.
    #   Represents the unit that the balances will be returned in.
    #   Note: this method interprets
    #   +:nano+ as NANO, which is technically Mnano
    #   See {https://nano.org/en/faq#what-are-nano-units- What are Nano's Units}
    #
    # @raise ArgumentError if an invalid +unit+ was given.
    def balance(unit: Nanook.default_unit)
      unless Nanook::UNITS.include?(unit)
        raise ArgumentError.new("Unsupported unit: #{unit}")
      end

      rpc(:account_balance).tap do |r|
        if unit == :nano
          r[:balance] = Nanook::Util.raw_to_NANO(r[:balance])
          r[:pending] = Nanook::Util.raw_to_NANO(r[:pending])
        end
      end
    end

    # Returns the id of the account.
    # @return [String] the id of the account
    def id
      @account
    end

    # Returns a Hash containing information about the account.
    #
    # ==== Example 1
    #
    #   account.info
    #
    # ==== Example 1 response
    #   {
    #     :id=>"xrb_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5"
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
    #     :id=>"xrb_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5"
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
    #
    # @param detailed [Boolean] (default is false). When +true+, four
    #   additional calls are made to the RPC to return more information
    # @param unit (see #balance)
    # @return [Hash] information about the account containing:
    #   [+id] The account id
    #   [+frontier+] The latest block hash
    #   [+open_block+] The first block in every account's blockchain. When this block was published the account was officially open
    #   [+representative_block+] The block that named the representative for the account
    #   [+balance+] Amount in {NANO}[https://nano.org/en/faq#what-are-nano-units-]
    #   [+last_modified+] Unix timestamp
    #   [+block_count+] Number of blocks in the account's blockchain
    #
    #   When <tt>detailed: true</tt> is passed as an argument, this method
    #   makes four additional calls to the RPC to return more information
    #   about an account:
    #
    #   [+weight+] See {#weight}
    #   [+pending+] See {#balance}
    #   [+representative+] See {#representative}
    #   [+public_key+] See {#public_key}
    def info(detailed: false, unit: Nanook.default_unit)
      unless Nanook::UNITS.include?(unit)
        raise ArgumentError.new("Unsupported unit: #{unit}")
      end

      response = rpc(:account_info)
      response.merge!(id: @account)

      if unit == :nano
        response[:balance] = Nanook::Util.raw_to_NANO(response[:balance])
      end

      # Return the response if we don't need any more info
      return response unless detailed

      # Otherwise make additional calls
      response.merge!({
        weight: weight,
        pending: balance(unit: unit)[:pending],
        representative: representative,
        public_key: public_key
      })

      # Sort this new hash by keys
      Hash[response.sort].to_symbolized_hash
    end

    def inspect
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
    #   account.ledger(limit: 2)
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
      rpc(:ledger, count: limit)[:accounts]
    end

    # Returns information about pending blocks (payments) that are
    # waiting to be received by the account.
    #
    # See also the #receive method of this class for how to receive a pending payment.
    #
    # The default response is an Array of block ids.
    #
    # With the +detailed:+ argument, the method returns an Array of Hashes,
    # which contain the source account id, amount pending and block id.
    #
    # ==== Example 1:
    #
    #   account.pending # => ["000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]
    #
    # ==== Example 2:
    #
    #   account.pending(detailed: true)
    #   # =>
    #   # [
    #   #   {
    #   #     :block=>"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F",
    #   #     :amount=>6,
    #   #     :source=>"xrb_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr"
    #   #   },
    #   #   { ... }
    #   # ]
    #
    # ==== Example 3:
    #
    #   account.pending(detailed: true, unit: raw).first[:amount] # => 6000000000000000000000000000000
    # @param limit [Integer] number of pending blocks to return (default is 1000)
    # @param detailed [Boolean]return a more complex Hash of pending block information (default is +false+)
    # @param unit (see #balance)
    #
    # @return [Array<String>]
    # @return [Array<Hash{Symbol=>String|Integer}>]
    def pending(limit: 1000, detailed: false, unit: Nanook.default_unit)
      unless Nanook::UNITS.include?(unit)
        raise ArgumentError.new("Unsupported unit: #{unit}")
      end

      params = { count: limit }
      params[:source] = true if detailed

      response = rpc(:pending, params)[:blocks]
      response = Nanook::Util.coerce_empty_string_to_type(response, (detailed ? Hash : Array))

      return response unless detailed

      response.map do |key, val|
        p = val.merge(block: key.to_s)

        if unit == :nano
          p[:amount] = Nanook::Util.raw_to_NANO(p[:amount])
        end

        p
      end
    end

    # Returns the account's weight.
    #
    # Weight is determined by the account's balance, and represents
    # the voting weight that account has on the network. Only accounts
    # with greater than 256 weight can vote.
    #
    # ==== Example:
    #   account.weight # => 0
    #
    # @return [Integer] the account's weight
    def weight
      rpc(:account_weight)[:weight]
    end

    private

    def rpc(action, params={})
      p = @account.nil? ? {} : { account: @account }
      @rpc.call(action, p.merge(params))
    end

  end
end
