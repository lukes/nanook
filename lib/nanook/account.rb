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

    # @param account [Nanook::Account] account to compare
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
    # This call may return results that include unconfirmed blocks, so it should not be used in
    # any processes or integrations requiring only details from blocks confirmed by the network.
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
    #      account: Nanook::Account,
    #      amount: 2,
    #      block: Nanook::Block
    #     }
    #   ]
    #
    # @param limit [Integer] maximum number of history items to return
    # @param unit (see #balance)
    # @return [Array<Hash{Symbol=>String|Float|Integer|Nanook::Account|NanookBlock}>] the history of send and receive payments for this account
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def history(limit: 1000, unit: Nanook.default_unit)
      Nanook.validate_unit!(unit)

      response = rpc(:account_history, count: limit)[:history]
      response = Nanook::Util.coerce_empty_string_to_type(response, Array)

      return response if unit == :raw

      response.map! do |history|
        history[:amount] = Nanook::Util.raw_to_NANO(history[:amount])
        history[:account] = Nanook::Account.new(@rpc, history[:account])
        history[:block] = Nanook::Block.new(@rpc, history.delete(:hash)) # We rename the key from `hash` to `block` here

        history
      end
    end

    # The last modified time of the account in UTC.
    #
    # ==== Example:
    #
    #   account.last_modified_at # => Time
    #
    # @return [Time] last modified time of the account in UTC. Can be nil
    def last_modified_at
      timestamp = rpc(:account_info)[:modified_timestamp]
      Time.at(timestamp).utc if timestamp
    end

    # The public key of the account.
    #
    # ==== Example:
    #
    #   account.public_key # => Nanook::PublicKey
    #
    # @return [Nanook::PublicKey] public key of the account
    def public_key
      Nanook::PublicKey.new(@rpc, rpc(:account_key)[:key])
    end

    # The representative for the account.
    #
    # ==== Example:
    #
    #   account.representative # => Nanook::Account
    #
    # @return [Nanook::Account] Representative of the account. Can be nil.
    def representative
      representative = rpc(:account_representative)[:representative]
      Nanook::Account.new(@rpc, representative) if representative
    end

    # The account's balance, including pending (unreceived payments).
    # To receive a pending amount see {WalletAccount#receive}.
    #
    # This call returns information that may be based on unconfirmed blocks.
    # These details should not be relied on for any process or integration that
    # requires confirmed blocks. The pending balance is calculated from
    # potentially unconfirmed blocks.
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
    #     frontier: Nanook::Block,
    #     last_modified_at: Time,
    #     open_block: Nanook::Block,
    #     pending: 1.0,
    #     representative: Nanook::Account,
    #     representative_block: Nanook::Block,
    #     weight: 0.1
    #   }
    #
    # @param unit (see #balance)
    # @return [Hash{Symbol=>String|Integer|Float|Nanook::Account|Nanook::Block|Time}] information about the account containing:
    #   [+id+] The account id
    #   [+frontier+] The latest {Nanook::Block}
    #   [+confirmation_height+] Confirmation height
    #   [+confirmation_height_frontier+] The {Nanook::Block} of the confirmation height
    #   [+pending+] Pending balance in either NANO or raw (depending on the <tt>unit:</tt> argument)
    #   [+open_block+] The first {Nanook::Block} in every account's blockchain. When this block was published the account was officially open
    #   [+representative_block+] The {Nanook::Block} that named the representative for the account
    #   [+balance+] Balance in either NANO or raw (depending on the <tt>unit:</tt> argument)
    #   [+last_modified_at+] {Time} of when the account was last modified in UTC
    #   [+representative+] Representative {Nanook::Account}
    #   [+block_count+] Number of blocks in the account's blockchain
    #   [+weight+] See {#weight}
    #
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def info(unit: Nanook.default_unit)
      Nanook.validate_unit!(unit)

      response = rpc(:account_info, representative: true, weight: true, pending: true)
      response.merge!(id: @account)
      response[:frontier] = Nanook::Block.new(@rpc, response[:frontier]) if response[:frontier]
      response[:open_block] = Nanook::Block.new(@rpc, response[:open_block]) if response[:open_block]
      response[:representative_block] = Nanook::Block.new(@rpc, response[:representative_block]) if response[:representative_block]
      response[:representative] = Nanook::Account.new(@rpc, response[:representative]) if response[:representative]
      response[:confirmation_height_frontier] = Nanook::Block.new(@rpc, response[:confirmation_height_frontier]) if response[:confirmation_height_frontier]
      response[:last_modified_at] = Time.at(response.delete(:modified_timestamp)).utc

      if unit == :nano
        response.merge!(
          balance: Nanook::Util.raw_to_NANO(response[:balance]),
          pending: Nanook::Util.raw_to_NANO(response[:pending]),
          weight: Nanook::Util.raw_to_NANO(response[:weight])
        )
      end

      response
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
    # @param limit [Integer] number of accounts to return in the ledger (default is 1)
    # @param modified_since [Time] return only accounts modified in the local database after this time
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
    #   account.pending # => [Nanook::Block, ..."]
    #
    # Asking for more detail to be returned:
    #
    #   account.pending(detailed: true)
    #
    # Example response:
    #
    #   [
    #     {
    #       block: Nanook::Block,
    #       amount: 6,
    #       source: Nanook::Account
    #     },
    #     { ... }
    #   ]
    #
    # @param limit [Integer] number of pending blocks to return (default is 1000)
    # @param detailed [Boolean]return a more complex Hash of pending block information (default is +false+)
    # @param unit (see #balance)
    #
    # @return [Array<Nanook::Block>]
    # @return [Array<Hash{Symbol=>Nanook::Block|Nanook::Account|Integer}>]
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def pending(limit: 1000, detailed: false, unit: Nanook.default_unit)
      Nanook.validate_unit!(unit)

      params = { count: limit }
      params[:source] = true if detailed

      response = rpc(:pending, params)[:blocks]
      response = Nanook::Util.coerce_empty_string_to_type(response, (detailed ? Hash : Array))

      unless detailed
        return response.map do |block|
          Nanook::Block.new(@rpc, block)
        end
      end

      response.map do |key, val|
        p = val.merge(
          block: Nanook::Block.new(@rpc, key.to_s),
          source: Nanook::Account.new(@rpc, val[:source])
        )

        p[:amount] = Nanook::Util.raw_to_NANO(p[:amount]) if unit == :nano
        p
      end
    end

    # The account's weight.
    #
    # Weight is determined by the account's balance, and represents
    # the voting weight that account has on the network. Only accounts
    # with greater than 0.1% of the online voting weight and are on a node
    # configured to vote can vote.
    #
    # ==== Example:
    #
    #   account.weight # => 0
    #
    # @return [Integer|Float] the account's weight
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def weight(unit: Nanook.default_unit)
      Nanook.validate_unit!(unit)

      weight = rpc(:account_weight)[:weight]

      return weight unless unit == :nano

      Nanook::Util.raw_to_NANO(weight)
    end

    private

    def rpc(action, params = {})
      p = @account.nil? ? {} : { account: @account }
      @rpc.call(action, p.merge(params))
    end
  end
end
