# frozen_string_literal: true

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
    def initialize(rpc, block)
      @rpc = rpc
      @block = block
      block_required! # All methods expect a block
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
    # starting at block back to count (direction from frontier back to
    # open block, from newer blocks to older). Will list all blocks back
    # to the open block of this chain when count is set to "-1".
    # The requested block hash is included in the answer.
    #
    # See also #successors.
    #
    # ==== Example:
    #
    #   block.chain(limit: 2)
    #
    # ==== Example reponse:
    #
    #   [
    #     "36A0FB717368BA8CF8D255B63DC207771EABC6C6FFC22A7F455EC2209464897E",
    #     "FBF8B0E6623A31AB528EBD839EEAA91CAFD25C12294C46754E45FD017F7939EB"
    #   ]
    #
    # @param limit [Integer] maximum number of block hashes to return (default is 1000)
    # @param offset [Integer] return the account chain block hashes offset by the specified number of blocks (default is 0)
    def chain(limit: 1000, offset: 0)
      response = rpc(:chain, :block, count: limit, offset: offset)[:blocks]
      Nanook::Util.coerce_empty_string_to_type(response, Array)
    end
    alias ancestors chain

    # Request confirmation for a block from online representative nodes.
    # Will return immediately with a boolean to indicate if the request for
    # confirmation was successful. Note that this boolean does not indicate
    # the confirmation status of the block. If confirmed, your block should
    # appear in {Nanook::Node#confirmation_history} within a short amount of
    # time, or you can use the convenience method {Nanook::Block#confirmed_recently?}
    #
    # ==== Example:
    #   block.confirm # => true
    #
    # @return [Boolean] if the confirmation request was sent successful
    def confirm
      rpc(:block_confirm, :hash)[:started] == 1
    end

    # This call is for internal diagnostics/debug purposes only. Do not
    # rely on this interface being stable and do not use in a production system.
    #
    # Check if the block appears in the list of recently confirmed blocks by
    # online representatives. The full list of blocks can be queried for with {Nanook::Node#confirmation_history}.
    #
    # This method can work in conjunction with {Nanook::Block#confirm},
    # whereby you can send any block (old or new) out to online representatives to
    # confirm. The confirmation process can take up to a couple of minutes.
    #
    # The method returning +false+ can indicate that the block is still in the process of being
    # confirmed and that you should call the method again soon, or that it
    # was confirmed earlier than the list available in {Nanook::Node#confirmation_history},
    # or that it was not confirmed.
    #
    # ==== Example:
    #   block.confirmed_recently? # => true
    #
    # @return [Boolean] +true+ if the block has been recently confirmed by
    #   online representatives.
    def confirmed_recently?
      @rpc.call(:confirmation_history)[:confirmations].map { |h| h[:hash] }.include?(@block)
    end
    alias recently_confirmed? confirmed_recently?

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
      rpc(:work_generate, :hash, use_peers: use_peers)[:work]
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
    #     :id=>"36A0FB717368BA8CF8D255B63DC207771EABC6C6FFC22A7F455EC2209464897E",
    #     :type=>"send",
    #     :previous=>"FBF8B0E6623A31AB528EBD839EEAA91CAFD25C12294C46754E45FD017F7939EB",
    #     :destination=>"nano_3x7cjioqahgs5ppheys6prpqtb4rdknked83chf97bot1unrbdkaux37t31b",
    #     :balance=>"00000000000000000000000000000000",
    #     :work=>"44cc24b60705083a",
    #     :signature=>"42ADFEFE7C3FFF188AE92A202F8A5734DE91779C454613E446EEC93D001D6C953E9FD16730AF32C891791BA8EDAECEB059A213E2FE1EEB7ADF9D5D0815464D06"
    #   }
    #
    # @param allow_unchecked [Boolean] (default is +false+). If +true+,
    #   information can be returned about blocks that are unchecked (unverified).
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def info(allow_unchecked: false, unit: Nanook.default_unit)
      Nanook.validate_unit!(unit)

      if allow_unchecked
        begin
          response = rpc(:unchecked_get, :hash, json_block: true)
          return parse_info_response(response, unit).merge(checked: false)
        rescue Nanook::Error
          # If unchecked not found, continue to checked block
        end
      end

      response = rpc(:block_info, :hash, json_block: true)
      parse_info_response(response, unit).merge(checked: true)
    end

    # ==== Example:
    #
    #   block.valid_work?("2bf29ef00786a6bc") # => true
    #
    # @param work [String] the work id to check is valid
    # @return [Boolean] signalling if work is valid for the block
    def valid_work?(work)
      response = rpc(:work_validate, :hash, work: work)
      !response.empty? && response[:valid] == 1
    end

    # Republish blocks starting at this block up the account chain
    # back to the nano network.
    #
    # @return [Array<String>] block hashes that were republished
    #
    # ==== Example:
    #
    #   block.republish
    #
    # ==== Example response:
    #
    #   ["36A0FB717368BA8CF8D255B63DC207771EABC6C6FFC22A7F455EC2209464897E"]
    def republish(destinations: nil, sources: nil)
      if !destinations.nil? && !sources.nil?
        raise ArgumentError, 'You must provide either destinations or sources but not both'
      end

      # Add in optional arguments
      params = {}
      params[:destinations] = destinations unless destinations.nil?
      params[:sources] = sources unless sources.nil?
      params[:count] = 1 unless params.empty?

      rpc(:republish, :hash, params)[:blocks]
    end

    # ==== Example:
    #
    #   block.pending? #=> false
    #
    # @return [Boolean] signalling if the block is a pending block.
    def pending?
      response = rpc(:pending_exists, :hash)
      !response.empty? && response[:exists] == 1
    end

    # Publish the block to the nano network.
    #
    # Note, if block has previously been published, use #republish instead.
    #
    # ==== Examples:
    #
    #   block.publish # => "FBF8B0E..."
    #
    # @return [String] the block hash, or false.
    def publish
      rpc(:process, :block)[:hash] || false
    end
    alias process publish

    # Returns an Array of block hashes in the account chain ending at
    # this block.
    #
    # See also #chain.
    #
    # ==== Example:
    #
    #   block.successors
    #
    # ==== Example response:
    #
    #   ["36A0FB717368BA8CF8D255B63DC207771EABC6C6FFC22A7F455EC2209464897E"]
    #
    # @param limit [Integer] maximum number of send/receive block hashes
    #   to return in the chain (default is 1000)
    # @param offset [Integer] return the account chain block hashes offset
    #   by the specified number of blocks (default is 0)
    # @return [Array<String>] block hashes in the account chain ending at this block
    def successors(limit: 1000, offset: 0)
      response = rpc(:successors, :block, count: limit, offset: offset)[:blocks]
      Nanook::Util.coerce_empty_string_to_type(response, Array)
    end

    # Returns the {Nanook::Account} of the block representative.
    #
    # ==== Example:
    #   block.representative # => Nanook::Account
    #
    # @return [Nanook::Account] representative account of the block. Can be nil.
    def representative
      representative = memoized_info[:representative]
      Nanook::Account.new(@rpc, representative) if representative
    end

    # Returns the {Nanook::Account} of the block.
    #
    # ==== Example:
    #   block.account # => Nanook::Account
    #
    # @return [Nanook::Account] the account of the block. Can be nil.
    def account
      account = memoized_info[:account]
      Nanook::Account.new(@rpc, account) if account
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
      Nanook.validate_unit!(unit)

      amount = memoized_info[:amount]
      return amount unless unit == :nano

      Nanook::Util.raw_to_NANO(amount)
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
      Nanook.validate_unit!(unit)

      balance = memoized_info[:balance]
      return balance unless unit == :nano

      Nanook::Util.raw_to_NANO(balance)
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
      timestamp = memoized_info[:local_timestamp]
      Time.at(timestamp).utc if timestamp
    end


    # Returns the {Nanook::Block} of the previous block in the chain.
    #
    # ==== Example:
    #   block.previous # => Nanook::Block
    #
    # @return [Nanook::Block] previous block in the chain. Can be nil.
    def previous
      block = memoized_info[:previous]
      Nanook::Block.new(@rpc, block) if block
    end

    # Returns true if block is checked.
    #
    # ==== Example:
    #   block.checked? # => true
    #
    # @return [Boolean]
    def checked?
      memoized_info[:checked] == true
    end

    # Returns true if block is unchecked.
    #
    # ==== Example:
    #   block.unchecked? # => true
    #
    # @return [Boolean]
    def unchecked?
      !checked?
    end

    # Returns the type of the block. One of "open", "send", "receive", "change", "epoch".
    #
    # ==== Example:
    #   block.type # => "open"
    #
    # @return [String] type of block.
    def type
      memoized_info[:subtype]
    end

    # Returns true if block is type "send".
    #
    # ==== Example:
    #   block.send? # => true
    #
    # @return [Boolean]
    def send?
      type == "send"
    end

    # Returns true if block is type "open".
    #
    # ==== Example:
    #   block.open? # => true
    #
    # @return [Boolean]
    def open?
      type == "open"
    end

    # Returns true if block is type "receive".
    #
    # ==== Example:
    #   block.receive? # => true
    #
    # @return [Boolean]
    def receive?
      type == "receive"
    end

    # Returns true if block is type "change" (change of representative).
    #
    # ==== Example:
    #   block.change? # => true
    #
    # @return [Boolean]
    def change?
      type == "change"
    end

    # Returns true if block is type "epoch".
    #
    # ==== Example:
    #   block.epoch? # => true
    #
    # @return [Boolean]
    def epoch?
      type == "epoch"
    end

    def inspect
      "#{self.class.name}(id: \"#{id}\", object_id: \"#{format('0x00%x', (object_id << 1))}\")"
    end

    private

    # Some RPC calls expect the param that represents the block to be named
    # "hash", and others "block".
    # The param_name argument allows us to specify which it should be for this call.
    def rpc(action, param_name, params = {})
      p = @block.nil? ? {} : { param_name.to_sym => @block }
      @rpc.call(action, p.merge(params))
    end

    # Memoize the `#info` response as we can refer to it for other methods (`type`, `#open?`, `#send?` etc.)
    def memoized_info
      @_memoized_info ||= info(allow_unchecked: true)
    end

    def block_required!
      raise ArgumentError, 'Block must be present' if @block.nil?
    end

    def parse_info_response(response, unit)
      response = Nanook::Util.coerce_empty_string_to_type(response, Hash)
      response.merge!(id: id)

      contents = response.delete(:contents)
      response.merge!(contents) if contents

      return response unless unit == :nano

      response[:amount] = Nanook::Util.raw_to_NANO(response[:amount])
      response[:balance] = Nanook::Util.raw_to_NANO(response[:balance])

      response.compact
    end
  end
end
