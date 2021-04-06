# frozen_string_literal: true

class Nanook
  # The <tt>Nanook::Account</tt> class contains methods to discover
  # publicly-available information about accounts on the nano network.
  #
  # === Initializing
  #
  # Initialize this class through the convenient {Nanook#account} method:
  #
  #   nanook = Nanook.new
  #   account = nanook.account("nano_...")
  #
  # Or compose the longhand way like this:
  #
  #   rpc_conn = Nanook::Rpc.new
  #   account = Nanook::Account.new(rpc_conn, "nano_...")
  class Account
    def initialize(rpc, account)
      @rpc = rpc
      @account = account
    end

    # The id of the account.
    #
    # ==== Example:
    #
    #   account.id # => "nano_16u..."
    #
    # @return [String] the id of the account
    def id
      @account
    end

    # @param [Nanook::Account] account to compare
    # @return [Boolean] true if accounts are equal
    def ==(account)
      account.class == self.class &&
        account.id == id
    end
    alias eql? ==

    # The hash value is used along with #eql? by the Hash class to determine if two objects
    # reference the same hash key.
    #
    # @return [Integer]
    def hash
      id.hash
    end

    # Information about this accounts that have set this account as their representative.
    #
    # === Example:
    #
    #   account.delegators
    #
    # Example response:
    #
    #   {
    #     :nano_13bqhi1cdqq8yb9szneoc38qk899d58i5rcrgdk5mkdm86hekpoez3zxw5sd=>500000000000000000000000000000000000,
    #     :nano_17k6ug685154an8gri9whhe5kb5z1mf5w6y39gokc1657sh95fegm8ht1zpn=>961647970820730000000000000000000000
    #   }
    #
    # @param unit (see #balance)
    # @return [Hash{Symbol=>Integer}] account ids which delegate to this account, and their account balance
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def delegators(unit: Nanook.default_unit)
      Nanook.validate_unit!(unit)

      response = rpc(:delegators)[:delegators]
      response = Nanook::Util.coerce_empty_string_to_type(response, Hash)

      return response if unit == :raw

      r = response.map do |account_id, balance|
        balance = Nanook::Util.raw_to_NANO(balance)

        [account_id, balance]
      end

      Hash[r].to_symbolized_hash
    end

    # Returns true if the account has an <i>open</i> block.
    #
    # An open block gets published when an account receives a payment
    # for the first time.
    #
    # The reliability of this check depends on the node host having
    # synchronized itself with most of the blocks on the nano network,
    # otherwise you may get +false+ when the account does exist.
    # You can check if a node's  synchronization is particular low
    # using {Nanook::Node#sync_progress}.
    #
    # ==== Example:
    #
    #   account.exists? # => true
    #   # or
    #   account.open?   # => true
    #
    # @return [Boolean] Indicates if this account has an open block
    def exists?
      begin
        response = rpc(:account_info)
      rescue Nanook::Error
        return false
      end

      !response.empty? && !response[:open_block].nil?
    end
    alias open? exists?

    # An account's history of send and receive payments.
    #
    # ==== Example:
    #
    #   account.history
    #
    # Example response:
    #
    #   [
    #     {
    #      type: "send",
    #      account: "nano_1kdc5u48j3hr5r7eof9iao47szqh81ndqgq5e5hrsn1g9a3sa4hkkcotn3uq",
    #      amount: 2,
    #      hash: "2C3C570EA8898443C0FD04A1C385A3E3A8C985AD792635FCDCEBB30ADF6A0570"
    #     }
    #   ]
    #
    # @param limit [Integer] maximum number of history items to return
    # @param unit (see #balance)
    # @return [Array<Hash{Symbol=>String}>] the history of send and receive payments for this account
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def history(limit: 1000, unit: Nanook.default_unit)
      Nanook.validate_unit!(unit)

      response = rpc(:account_history, count: limit)[:history]
      response = Nanook::Util.coerce_empty_string_to_type(response, Array)

      return response if unit == :raw

      response.map! do |history|
        history[:amount] = Nanook::Util.raw_to_NANO(history[:amount])
        history
      end
    end

    # The last modified time of the account in the time zone of
    # your nano node (usually UTC).
    #
    # ==== Example:
    #
    #   account.last_modified_at # => Time
    #
    # @return [Time] last modified time of the account in the time zone of
    #   your nano node (usually UTC).
    def last_modified_at
      response = rpc(:account_info)
      Time.at(response[:modified_timestamp])
    end

    # The public key of the account.
    #
    # ==== Example:
    #
    #   account.public_key # => "3068BB1..."
    #
    # @return [String] public key of the account
    def public_key
      rpc(:account_key)[:key]
    end

    # The representative account id for the account.
    # Representatives are accounts that cast votes in the case of a
    # fork in the network.
    #
    # ==== Example:
    #
    #   account.representative # => "nano_3pc..."
    #
    # @return [String] Representative account of the account
    def representative
      rpc(:account_representative)[:representative]
    end

    # The account's balance, including pending (unreceived payments).
    # To receive a pending amount see {WalletAccount#receive}.
    #
    # ==== Examples:
    #
    #   account.balance
    #
    # Example response:
    #
    #   {
    #     balance: 2,
    #     pending: 1.1
    #   }
    #
    # Asking for the balance to be returned in raw instead of NANO:
    #
    #   account.balance(unit: :raw)
    #
    # Example response:
    #
    #   {
    #     balance: 2000000000000000000000000000000,
    #     pending: 1100000000000000000000000000000
    #   }
    #
    # @param unit [Symbol] default is {Nanook.default_unit}.
    #   Must be one of {Nanook::UNITS}.
    #   Represents the unit that the balances will be returned in.
    #   Note: this method interprets
    #   +:nano+ as NANO, which is technically Mnano.
    #   See {https://docs.nano.org/protocol-design/distribution-and-units/#unit-dividers What are Nano's Units}
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    # @return [Hash{Symbol=>Integer|Float}]
    def balance(unit: Nanook.default_unit)
      Nanook.validate_unit!(unit)

      rpc(:account_balance).tap do |r|
        if unit == :nano
          r[:balance] = Nanook::Util.raw_to_NANO(r[:balance])
          r[:pending] = Nanook::Util.raw_to_NANO(r[:pending])
        end
      end
    end

    # @return [Integer] number of blocks for this account
    def block_count
      rpc(:account_block_count)[:block_count]
    end

    # Information about the account.
    #
    # ==== Examples:
    #
    #   account.info
    #
    # Example response:
    #
    #   {
    #     id: "nano_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5",
    #     balance: 11.439597000000001,
    #     block_count: 4,
    #     frontier: "2C3C570EA8898443C0FD04A1C385A3E3A8C985AD792635FCDCEBB30ADF6A0570",
    #     modified_timestamp: 1520500357,
    #     open_block: "C82376314C387080A753871A32AD70F4168080C317C5E67356F0A62EB5F34FF9",
    #     representative_block: "C82376314C387080A753871A32AD70F4168080C317C5E67356F0A62EB5F34FF9"
    #   }
    #
    # Asking for more detail to be returned:
    #
    #   account.info(detailed: true)
    #
    # Example response:
    #
    #   {
    #     id: "nano_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5",
    #     balance: 11.439597000000001,
    #     block_count: 4,
    #     frontier: "2C3C570EA8898443C0FD04A1C385A3E3A8C985AD792635FCDCEBB30ADF6A0570",
    #     modified_timestamp: 1520500357,
    #     open_block: "C82376314C387080A753871A32AD70F4168080C317C5E67356F0A62EB5F34FF9",
    #     pending: 0,
    #     public_key: "A82C906460046D230D7D37C6663723DC3EFCECC4B3254EBF45294B66746F4FEF",
    #     representative: "nano_3pczxuorp48td8645bs3m6c3xotxd3idskrenmi65rbrga5zmkemzhwkaznh",
    #     representative_block: "C82376314C387080A753871A32AD70F4168080C317C5E67356F0A62EB5F34FF9",
    #     weight: 0
    #   }
    #
    # @param detailed [Boolean] (default is false). When +true+, four
    #   additional calls are made to the RPC to return more information
    # @param unit (see #balance)
    # @return [Hash{Symbol=>String|Integer|Float}] information about the account containing:
    #   [+id+] The account id
    #   [+frontier+] The latest block hash
    #   [+open_block+] The first block in every account's blockchain. When this block was published the account was officially open
    #   [+representative_block+] The block that named the representative for the account
    #   [+balance+] Amount in either NANO or raw (depending on the <tt>unit:</tt> argument)
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
    #
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def info(detailed: false, unit: Nanook.default_unit)
      Nanook.validate_unit!(unit)

      response = rpc(:account_info)
      response.merge!(id: @account)

      response[:balance] = Nanook::Util.raw_to_NANO(response[:balance]) if unit == :nano

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
      "#{self.class.name}(id: \"#{id}\", object_id: \"#{format('0x00%x', (object_id << 1))}\")"
    end

    # Information about the given account as well as other
    # accounts up the ledger. The number of accounts returned is determined
    # by the <tt>limit:</tt> argument.
    #
    # ==== Example:
    #
    #   account.ledger(limit: 2)
    #
    # Example response:
    #
    #   {
    #    :nano_3c3ek3k8135f6e8qtfy8eruk9q3yzmpebes7btzncccdest8ymzhjmnr196j=>{
    #      :frontier=>"2C3C570EA8898443C0FD04A1C385A3E3A8C985AD792635FCDCEBB30ADF6A0570",
    #      :open_block=>"C82376314C387080A753871A32AD70F4168080C317C5E67356F0A62EB5F34FF9",
    #      :representative_block=>"C82376314C387080A753871A32AD70F4168080C317C5E67356F0A62EB5F34FF9",
    #      :balance=>11439597000000000000000000000000,
    #      :modified_timestamp=>1520500357,
    #      :block_count=>4
    #    },
    #    :nano_3c3ettq59kijuuad5fnaq35itc9schtr4r7r6rjhmwjbairowzq3wi5ap7h8=>{ ... }
    #  }
    #
    # @param [Integer] limit number of accounts to return in the ledger (default is 1)
    # @param [Time] modified_since return only accounts modified in the local database after this time
    # @param unit (see #balance)
    # @return [Hash{Symbol=>String|Integer}]
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def ledger(limit: 1, modified_since: nil, unit: Nanook.default_unit)
      Nanook.validate_unit!(unit)

      params = { count: limit }

      params[:modified_since] = modified_since.to_i unless modified_since.nil?

      response = rpc(:ledger, params)[:accounts]
      response = Nanook::Util.coerce_empty_string_to_type(response, Hash)

      return response if unit == :raw

      r = response.map do |account_id, l|
        l[:balance] = Nanook::Util.raw_to_NANO(l[:balance])

        [account_id, l]
      end

      Hash[r].to_symbolized_hash
    end

    # Information about pending blocks (payments) that are
    # waiting to be received by the account.
    #
    # See also the {Nanook::WalletAccount#receive} method for how to
    # receive a pending payment.
    #
    # The default response is an Array of block ids.
    #
    # With the +detailed:+ argument, the method returns an Array of Hashes,
    # which contain the source account id, amount pending and block id.
    #
    # ==== Examples:
    #
    #   account.pending # => ["000D1BA..."]
    #
    # Asking for more detail to be returned:
    #
    #   account.pending(detailed: true)
    #
    # Example response:
    #
    #   [
    #     {
    #       block: "000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F",
    #       amount: 6,
    #       source: "nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr"
    #     },
    #     { ... }
    #   ]
    #
    # @param limit [Integer] number of pending blocks to return (default is 1000)
    # @param detailed [Boolean]return a more complex Hash of pending block information (default is +false+)
    # @param unit (see #balance)
    #
    # @return [Array<String>]
    # @return [Array<Hash{Symbol=>String|Integer}>]
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def pending(limit: 1000, detailed: false, unit: Nanook.default_unit)
      Nanook.validate_unit!(unit)

      params = { count: limit }
      params[:source] = true if detailed

      response = rpc(:pending, params)[:blocks]
      response = Nanook::Util.coerce_empty_string_to_type(response, (detailed ? Hash : Array))

      return response unless detailed

      response.map do |key, val|
        p = val.merge(block: key.to_s)

        p[:amount] = Nanook::Util.raw_to_NANO(p[:amount]) if unit == :nano

        p
      end
    end

    # The account's weight.
    #
    # Weight is determined by the account's balance, and represents
    # the voting weight that account has on the network. Only accounts
    # with greater than 256 weight can vote.
    #
    # ==== Example:
    #
    #   account.weight # => 0
    #
    # @return [Integer] the account's weight
    def weight
      rpc(:account_weight)[:weight]
    end

    private

    def rpc(action, params = {})
      p = @account.nil? ? {} : { account: @account }
      @rpc.call(action, p.merge(params))
    end
  end
end
