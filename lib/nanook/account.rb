# frozen_string_literal: true

require_relative 'util'

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
    include Nanook::Util

    def initialize(rpc, account)
      @rpc = rpc
      @account = account.to_s
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

    # @param other [Nanook::Account] account to compare
    # @return [Boolean] true if accounts are equal
    def ==(other)
      other.class == self.class &&
        other.id == id
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
    #     Nanook::Account=>50.0,
    #     Nanook::Account=>961.64
    #   }
    #
    # @param unit (see #balance)
    # @return [Hash{Nanook::Account=>Integer|Float}] {Nanook::Account} accounts which delegate to this account, and their account balance
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def delegators(unit: Nanook.default_unit)
      validate_unit!(unit)

      response = rpc(:delegators, _access: :delegators, _coerce: Hash)

      r = response.map do |account_id, balance|
        balance = raw_to_NANO(balance) if unit == :nano

        [as_account(account_id), balance]
      end

      Hash[r]
    end

    # Number of accounts that have set this account as their representative.
    #
    # === Example:
    #
    #   account.delegators_count # => 2
    #
    # @return [Integer]
    def delegators_count
      rpc(:delegators_count, _access: :count)
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
    # @param limit [Integer] maximum number of history items to return. Defaults to 1000
    # @param sort [Symbol] default +:asc+. When set to +:desc+ the history will be returned oldest to newest.
    # @param unit (see #balance)
    # @return [Array<Hash{Symbol=>String|Float|Integer|Nanook::Account|NanookBlock}>] the history of send and receive payments for this account
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def history(limit: 1000, unit: Nanook.default_unit, sort: :asc)
      validate_unit!(unit)

      response = rpc(:account_history, count: limit, reverse: (sort == :desc), _access: :history, _coerce: Array)

      response.map do |history|
        history[:amount] = raw_to_NANO(history[:amount]) if unit == :nano
        history[:account] = as_account(history[:account])
        history[:block] = as_block(history.delete(:hash)) # Rename the key from `hash` to `block`

        history
      end
    end

    # Return blocks for the account.
    #
    # @param limit [Integer] maximum number of history items to return. Defaults to 1000
    # @param sort [Symbol] default +:asc+. When set to +:desc+ the blocks will be returned oldest to newest.
    # @return [Array<Nanook::Block>]
    def blocks(limit: 1000, sort: :asc)
      history(limit: limit, sort: sort).map { |i| i[:block] }
    end

    # Returns the open block for the account if it exists on the node.
    #
    # @return [Nanook::Block]
    def open_block
      blocks(limit: 1, sort: :desc).first
    end

    # The last modified time of the account in UTC. For many accounts on the node
    # this will be the timestamp of when the node bootstrapped.
    #
    # ==== Example:
    #
    #   account.last_modified_at # => Time
    #
    # @return [Time] last modified time of the account in UTC. Can be nil
    def last_modified_at
      as_time(rpc(:account_info, _access: :modified_timestamp))
    end

    # The public key of the account.
    #
    # ==== Example:
    #
    #   account.public_key # => Nanook::PublicKey
    #
    # @return [Nanook::PublicKey] public key of the account
    def public_key
      as_public_key(rpc(:account_key, _access: :key))
    end

    # The representative for the account.
    #
    # ==== Example:
    #
    #   account.representative # => Nanook::Account
    #
    # @return [Nanook::Account] Representative of the account. Can be nil.
    def representative
      representative = rpc(:account_representative, _access: :representative)
      as_account(representative) if representative
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
      validate_unit!(unit)

      rpc(:account_balance).tap do |r|
        if unit == :nano
          r[:balance] = raw_to_NANO(r[:balance])
          r[:pending] = raw_to_NANO(r[:pending])
        end
      end
    end

    # @return [Integer] number of blocks for this account
    def block_count
      rpc(:account_block_count, _access: :block_count)
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
    #   [+last_modified_at+] Time of when the account was last modified in UTC
    #   [+representative+] Representative {Nanook::Account}
    #   [+block_count+] Number of blocks in the account's blockchain
    #   [+weight+] See {#weight}
    #
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def info(unit: Nanook.default_unit)
      validate_unit!(unit)

      response = rpc(:account_info, representative: true, weight: true, pending: true)
      response.merge!(id: @account)
      response[:frontier] = as_block(response[:frontier]) if response[:frontier]
      response[:open_block] = as_block(response[:open_block]) if response[:open_block]
      response[:representative_block] = as_block(response[:representative_block]) if response[:representative_block]
      response[:representative] = as_account(response[:representative]) if response[:representative]
      response[:confirmation_height_frontier] = as_block(response[:confirmation_height_frontier]) if response[:confirmation_height_frontier]
      response[:last_modified_at] = as_time(response.delete(:modified_timestamp))

      if unit == :nano
        response.merge!(
          balance: raw_to_NANO(response[:balance]),
          pending: raw_to_NANO(response[:pending]),
          weight: raw_to_NANO(response[:weight])
        )
      end

      response
    end

    # @return [String]
    def to_s
      "#{self.class.name}(id: \"#{short_id}\")"
    end
    alias inspect to_s

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
    #    Nanook::Account => {
    #      :frontier => Nanook::Block,
    #      :open_block => Nanook::Block,
    #      :representative_block => Nanook::Block,
    #      :representative => Nanook::Account,
    #      :balance => 1143.7,
    #      :last_modified_at => Time,
    #      :block_count => 4
    #      :weight => 5
    #      :pending => 2.0
    #    },
    #    Nanook::Account => { ... }
    #  }
    #
    # @param limit [Integer] number of accounts to return in the ledger (default is 1000)
    # @param modified_since [Time] optional. Return only accounts modified in the local database after this time (default is from the unix epoch)
    # @param unit (see #balance)
    # @param sort [Symbol] default +:asc+. When set to +:desc+ the ledger will be returned oldest to newest.
    # @return [Hash{Nanook::Account=>String|Integer}]
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def ledger(limit: 1000, modified_since: 0, unit: Nanook.default_unit, sort: :asc)
      validate_unit!(unit)

      params = {
        count: limit,
        sorting: (sort == :desc),
        modified_since: modified_since.to_i,
        _access: :accounts,
        _coerce: Hash
      }

      response = rpc(:ledger, params)

      r = response.map do |account_id, ledger|
        if unit == :nano
          ledger[:balance] = raw_to_NANO(ledger[:balance])
          ledger[:pending] = raw_to_NANO(ledger[:pending])
          ledger[:weight] = raw_to_NANO(ledger[:weight])
        end

        ledger[:last_modified_at] = as_time(ledger.delete(:modified_timestamp))
        ledger[:representative] = as_account(ledger[:representative]) if ledger[:representative]
        ledger[:representative_block] = as_block(ledger[:representative_block]) if ledger[:representative_block]
        ledger[:open_block] = as_block(ledger[:open_block]) if ledger[:open_block]
        ledger[:frontier] = as_block(ledger[:frontier]) if ledger[:frontier]

        [as_account(account_id), ledger]
      end

      Hash[r]
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
      validate_unit!(unit)

      params = {
        count: limit,
        _access: :blocks,
        _coerce: (detailed ? Hash : Array)
      }
      params[:source] = true if detailed

      response = rpc(:pending, params)

      unless detailed
        return response.map do |block|
          as_block(block)
        end
      end

      response.map do |key, val|
        p = val.merge(
          block: as_block(key.to_s),
          source: as_account(val[:source])
        )

        p[:amount] = raw_to_NANO(p[:amount]) if unit == :nano
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
      validate_unit!(unit)

      weight = rpc(:account_weight, _access: :weight)

      return weight unless unit == :nano

      raw_to_NANO(weight)
    end

    private

    def rpc(action, params = {})
      @rpc.call(action, { account: @account }.merge(params))
    end
  end
end
