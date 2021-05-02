# frozen_string_literal: true

require_relative 'util'

class Nanook
  # The <tt>Nanook::Block</tt> class contains methods to discover
  # publicly-available information about blocks on the nano network.
  #
  # A block is represented by a unique id like this:
  #
  #   "FBF8B0E6623A31AB528EBD839EEAA91CAFD25C12294C46754E45FD017F7939EB"
  #
  # Initialize this class through the convenient Nanook#block method:
  #
  #   nanook = Nanook.new
  #   block = nanook.block("FBF8B0E...")
  #
  # Or compose the longhand way like this:
  #
  #   rpc_conn = Nanook::Rpc.new
  #   block = Nanook::Block.new(rpc_conn, "FBF8B0E...")
  class Block
    include Nanook::Util

    def initialize(rpc, block)
      @rpc = rpc
      @block = block.to_s
    end

    # Returns the block hash id.
    #
    # ==== Example:
    #
    #   block.id #=> "FBF8B0E..."
    #
    # @return [String] the block hash id
    def id
      @block
    end

    # @param other [Nanook::Block] block to compare
    # @return [Boolean] true if blocks are equal
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

    # Stop generating work for a block.
    #
    # ==== Example:
    #
    #   block.cancel_work # => true
    #
    # @return [Boolean] signalling if the action was successful
    def cancel_work
      rpc(:work_cancel, :hash).empty?
    end

    # Returns a consecutive list of block hashes in the account chain
    # from (but not including) block back to +count+ (direction from frontier back to
    # open block, from newer blocks to older). Will list all blocks back
    # to the open block of this chain when count is set to "-1".
    #
    # See also #descendants.
    #
    # ==== Example:
    #
    #   block.ancestors(limit: 2)
    #
    # ==== Example reponse:
    #
    #   [Nanook::Block, ...]
    #
    # @param limit [Integer] maximum number of block hashes to return (default is 1000)
    # @param offset [Integer] return the account chain block hashes offset by the specified number of blocks (default is 0)
    def chain(limit: 1000, offset: 0)
      # The RPC includes this block in its response, and Nanook will remove it from the results.
      # Increment the limit by 1 to account for this (a limit of -1 is valid and means no limit).
      limit += 1 if limit > 0
      params = {
        count: limit,
        offset: offset,
        _access: :blocks,
        _coerce: Array
      }

      response = rpc(:chain, :block, params)[1..].to_a
      response.map { |block| as_block(block) }
    end
    alias ancestors chain

    # Request confirmation for a block from online representative nodes.
    # Will return immediately with a boolean to indicate if the request for
    # confirmation was successful. Note that this boolean does not indicate
    # the confirmation status of the block.
    #
    # ==== Example:
    #   block.confirm # => true
    #
    # @return [Boolean] if the confirmation request was sent successful
    def confirm
      rpc(:block_confirm, :hash, _access: :started) == 1
    end

    # Generate work for a block.
    #
    # ==== Example:
    #   block.generate_work # => "2bf29ef00786a6bc"
    #
    # @param use_peers [Boolean] if set to +true+, then the node will query
    #   its work peers (if it has any, see {Nanook::WorkPeer#list}).
    #   When +false+, the node will only generate work locally (default is +false+)
    # @return [String] the work id of the work completed.
    def generate_work(use_peers: false)
      rpc(:work_generate, :hash, use_peers: use_peers, _access: :work)
    end

    # Returns a Hash of information about the block.
    #
    # ==== Examples:
    #
    #   block.info
    #   block.info(allow_unchecked: true)
    #
    # ==== Example response:
    #
    #   {
    #     "account": Nanook::Account,
    #     "amount": 34.2,
    #     "balance": 2.3
    #     "height": 58,
    #     "local_timestamp": Time,
    #     "confirmed": true,
    #     "type": "send",
    #     "account": Nanook::Account,
    #     "previous": Nanook::Block,
    #     "representative": Nanook::Account,
    #     "link": Nanook::Block,
    #     "link_as_account": Nanook::Account,
    #     "signature": "82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501",
    #     "work": "8a142e07a10996d5"
    #   }
    #
    # @param allow_unchecked [Boolean] (default is +false+). If +true+,
    #   information can be returned about blocks that are unchecked (unverified).
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    # @raise [Nanook::NodeRpcError] if block is not found on the node.
    def info(allow_unchecked: false, unit: Nanook.default_unit)
      validate_unit!(unit)

      # Params for both `unchecked_get` and `block_info` calls
      params = {
        json_block: true,
        _coerce: Hash
      }

      begin
        response = rpc(:block_info, :hash, params)
        response.merge!(confirmed: true)
      rescue Nanook::NodeRpcError => e
        raise e unless allow_unchecked

        response = rpc(:unchecked_get, :hash, params)
        response.merge!(confirmed: false)
      end

      parse_info_response(response, unit)
    end

    # Returns true if work is valid for the block.
    #
    # ==== Example:
    #
    #   block.valid_work?("2bf29ef00786a6bc") # => true
    #
    # @param work [String] the work id to check is valid
    # @return [Boolean] signalling if work is valid for the block
    def valid_work?(work)
      response = rpc(:work_validate, :hash, work: work)
      response[:valid_all] == 1 || response[:valid_receive] == 1
    end

    # Republish blocks starting at this block up the account chain
    # back to the nano network.
    #
    # @return [Array<Nanook::Block>] blocks that were republished
    #
    # ==== Example:
    #
    #   block.republish # => [Nanook::Block, ...]
    def republish(destinations: nil, sources: nil)
      if !destinations.nil? && !sources.nil?
        raise ArgumentError, 'You must provide either destinations or sources but not both'
      end

      params = {
        _access: :blocks,
        _coerce: Array
      }

      params[:destinations] = destinations unless destinations.nil?
      params[:sources] = sources unless sources.nil?
      params[:count] = 1 if destinations || sources

      rpc(:republish, :hash, params).map do |block|
        as_block(block)
      end
    end

    # Returns true if block is a pending block.
    #
    # ==== Example:
    #
    #   block.pending? #=> false
    #
    # @return [Boolean] signalling if the block is a pending block.
    def pending?
      rpc(:pending_exists, :hash, _access: :exists) == 1
    end

    # Returns an Array of block hashes in the account chain from (but not including) this block up to +count+
    # (direction from open block up to frontier, from older blocks to newer). Will list all
    # blocks up to frontier (latest block) of this chain when +count+ is set to +-1+.
    #
    # See also #ancestors.
    #
    # ==== Example:
    #
    #   block.descendants # => [Nanook::Block, .. ]
    #
    # @param limit [Integer] maximum number of send/receive block hashes
    #   to return in the chain (default is 1000)
    # @param offset [Integer] return the account chain block hashes offset
    #   by the specified number of blocks (default is 0)
    # @return [Array<Nanook::Block>] blocks in the account chain ending at this block
    def successors(limit: 1000, offset: 0)
      # The RPC includes this block in its response, and Nanook will remove it from the results.
      # Increment the limit by 1 to account for this (a limit of -1 is valid and means no limit).
      limit += 1 if limit > 0

      params = {
        count: limit,
        offset: offset,
        _access: :blocks,
        _coerce: Array
      }

      response = rpc(:successors, :block, params)[1..].to_a
      response.map { |block| as_block(block) }
    end
    alias descendants successors

    # Returns the {Nanook::Account} of the block representative.
    #
    # ==== Example:
    #   block.representative # => Nanook::Account
    #
    # @return [Nanook::Account] representative account of the block. Can be nil.
    def representative
      memoized_info[:representative]
    end

    # Returns the {Nanook::Account} of the block.
    #
    # ==== Example:
    #   block.account # => Nanook::Account
    #
    # @return [Nanook::Account] the account of the block. Can be nil.
    def account
      memoized_info[:account]
    end

    # Returns the amount of the block.
    #
    # ==== Example:
    #   block.amount # => 3.01
    #
    # @param unit (see Nanook::Account#balance)
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    # @return [Float]
    def amount(unit: Nanook.default_unit)
      validate_unit!(unit)

      amount = memoized_info[:amount]
      return amount unless unit == :nano

      raw_to_NANO(amount)
    end

    # Returns the balance of the account at the time the block was created.
    #
    # ==== Example:
    #   block.balance # => 3.01
    #
    # @param unit (see Nanook::Account#balance)
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    # @return [Float]
    def balance(unit: Nanook.default_unit)
      validate_unit!(unit)

      balance = memoized_info[:balance]
      return balance unless unit == :nano

      raw_to_NANO(balance)
    end

    # Returns true if block is confirmed.
    #
    # ==== Example:
    #   block.confirmed # => true
    #
    # @return [Boolean]
    def confirmed?
      memoized_info[:confirmed]
    end
    alias checked? confirmed?

    # Returns true if block is unconfirmed.
    #
    # ==== Example:
    #   block.unconfirmed? # => true
    #
    # @return [Boolean]
    def unconfirmed?
      !confirmed?
    end
    alias unchecked? unconfirmed?

    # Returns true if block exists in the node's ledger. This will return
    # false for blocks that exist on the nano ledger but have not yet
    # synchronized to the node.
    #
    # ==== Example:
    #
    #   block.exists? # => false
    #   block.exists?(allow_unchecked: true) # => true
    #
    # @param allow_unchecked [Boolean] defaults to +false+
    # @return [Boolean]
    def exists?(allow_unchecked: false)
      begin
        allow_unchecked ? memoized_info : info
      rescue Nanook::NodeRpcError
        return false
      end

      true
    end

    # Returns the {Nanook::Block} of the next (newer) block in the account chain.
    #
    # ==== Example:
    #   block.next # => Nanook::Block
    #
    # @return [Nanook::Block] next (newer) block in the account chain. Can be nil.
    def next
      successors(limit: 1).first
    end

    # Returns the height of the block.
    #
    # ==== Example:
    #   block.height # => 5
    #
    # @return [Integer]
    def height
      memoized_info[:height]
    end

    # Returns the block work.
    #
    # ==== Example:
    #   block.work # => "8a142e07a10996d5"
    #
    # @return [String]
    def work
      memoized_info[:work]
    end

    # Returns the block signature.
    #
    # ==== Example:
    #   block.signature # => "82D41BC16F313E4B2243D14DFFA2FB04679C540C2095FEE7EAE0F2F26880AD56DD48D87A7CC5DD760C5B2D76EE2C205506AA557BF00B60D8DEE312EC7343A501"
    #
    # @return [String]
    def signature
      memoized_info[:signature]
    end

    # Returns the timestamp of when the node saw the block.
    #
    # ==== Example:
    #   block.timestamp # => 2018-05-30 16:41:48 UTC
    #
    # @return [Time] Time in UTC of when the node saw the block. Can be nil.
    def timestamp
      memoized_info[:local_timestamp]
    end

    # Returns the {Nanook::Block} of the previous (older) block in the account chain.
    #
    # ==== Example:
    #   block.previous # => Nanook::Block
    #
    # @return [Nanook::Block] previous (older) block in the account chain. Can be nil.
    def previous
      memoized_info[:previous]
    end

    # Returns the type of the block. One of "open", "send", "receive", "change", "epoch".
    #
    # ==== Example:
    #   block.type # => "open"
    #
    # @return [String] type of block. Returns nil for unconfirmed blocks.
    def type
      memoized_info[:type]
    end

    # Returns true if block is type "send".
    #
    # ==== Example:
    #   block.send? # => true
    #
    # @return [Boolean]
    def send?
      type == 'send'
    end

    # Returns true if block is type "open".
    #
    # ==== Example:
    #   block.open? # => true
    #
    # @return [Boolean]
    def open?
      type == 'open'
    end

    # Returns true if block is type "receive".
    #
    # ==== Example:
    #   block.receive? # => true
    #
    # @return [Boolean]
    def receive?
      type == 'receive'
    end

    # Returns true if block is type "change" (change of representative).
    #
    # ==== Example:
    #   block.change? # => true
    #
    # @return [Boolean]
    def change?
      type == 'change'
    end

    # Returns true if block is type "epoch".
    #
    # ==== Example:
    #   block.epoch? # => true
    #
    # @return [Boolean]
    def epoch?
      type == 'epoch'
    end

    # @return [String]
    def to_s
      "#{self.class.name}(id: \"#{short_id}\")"
    end
    alias inspect to_s

    private

    # Some RPC calls expect the param that represents the block to be named
    # "hash", and others "block".
    # The param_name argument allows us to specify which it should be for this call.
    def rpc(action, param_name, params = {})
      p = { param_name.to_sym => @block }
      @rpc.call(action, p.merge(params))
    end

    # Memoize the `#info` response as we can refer to it for other methods (`type`, `#open?`, `#send?` etc.)
    def memoized_info
      @memoized_info ||= info(allow_unchecked: true, unit: :raw)
    end

    def parse_info_response(response, unit)
      response.merge!(id: id)
      contents = response.delete(:contents)
      response.merge!(contents) if contents

      response.delete(:block_account) # duplicate of contents.account
      response[:last_modified_at] = response.delete(:modified_timestamp) # rename key

      # `type` can be "open", "send", "receive", "change", "epoch" or "state".
      # blocks with `type` == "state" may have a `subtype` that gives more information
      # about the block ("send", "receive", "change", "epoch"), in which case replace
      # the `type` with this value.
      if response[:type] == 'state' && (subtype = response.delete(:subtype))
        response[:type] = subtype
      end

      response[:account] = as_account(response[:account]) if response[:account]
      response[:representative] = as_account(response[:representative]) if response[:representative]
      response[:previous] = as_block(response[:previous]) if response[:previous]
      response[:link] = as_block(response[:link]) if response[:link]
      response[:link_as_account] = as_account(response[:link_as_account]) if response[:link_as_account]
      response[:local_timestamp] = as_time(response[:local_timestamp])
      response[:last_modified_at] = as_time(response[:last_modified_at])

      if unit == :nano
        response[:amount] = raw_to_NANO(response[:amount])
        response[:balance] = raw_to_NANO(response[:balance])
      end

      response.compact
    end
  end
end
