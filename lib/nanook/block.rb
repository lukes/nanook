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
  #   account = nanook.block("FBF8B0E...")
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

    # Returns the {Nanook::Account} of the block.
    #
    # ==== Example:
    #   block.account # => Nanook::Account
    #
    # @return [Nanook::Account] the account of the block
    def account
      Nanook::Account.new(@rpc, rpc(:block_account, :hash)[:account])
    end

    # Stop generating work for a block.
    #
    # Returns boolean signalling if the action was successful.
    #
    # ==== Example
    #
    #   block.cancel_work # => true
    def cancel_work
      rpc(:work_cancel, :hash).empty?
    end

    # Returns an Array of block hashes in the account chain starting at
    # this block.
    #
    # See also #successors.
    #
    # ==== Arguments
    #
    # [+limit:+] Maximum number of block hashes to return (default is 1000)
    #
    # ==== Example
    #
    #   block.chain(limit: 2)
    #
    # ==== Example reponse
    #
    #   [
    #     "36A0FB717368BA8CF8D255B63DC207771EABC6C6FFC22A7F455EC2209464897E",
    #     "FBF8B0E6623A31AB528EBD839EEAA91CAFD25C12294C46754E45FD017F7939EB"
    #   ]
    def chain(limit: 1000)
      response = rpc(:chain, :block, count: limit)[:blocks]
      Nanook::Util.coerce_empty_string_to_type(response, Array)
    end

    # Generate work for a block.
    #
    # Returns the work id of the work completed.
    #
    #   block.generate_work # => "2bf29ef00786a6bc"
    def generate_work
      rpc(:work_generate, :hash)[:work]
    end

    # Returns Array of Hashes containing information about a chain of
    # send/receive blocks, starting from this block.
    #
    # ==== Arguments
    #
    # [+limit:+] Maximum number of send/receive block hashes to return
    #            in the chain (default is 1000)
    #
    # ==== Example
    #
    #   block.history(limit: 1)
    #
    # ==== Example response
    #
    #   [
    #     {
    #       :account=>"xrb_3x7cjioqahgs5ppheys6prpqtb4rdknked83chf97bot1unrbdkaux37t31b",
    #       :amount=>539834279601145558517940224,
    #       :hash=>"36A0FB717368BA8CF8D255B63DC207771EABC6C6FFC22A7F455EC2209464897E",
    #       :type=>"send"
    #     }
    #   ]
    def history(limit: 1000)
      rpc(:history, :hash, count: limit)[:history]
    end

    # Returns the block hash
    #
    #   block.id #=> "FBF8B0E..."
    def id
      @block
    end

    # Returns a Hash of information about the block.
    #
    # ==== Arguments
    #
    # [+allow_unchecked:+] Boolean (default is +false+). If +true+,
    #                      information can be returned about blocks that
    #                      are unchecked (unverified).
    # ==== Example response
    #
    #   {
    #     :id=>"36A0FB717368BA8CF8D255B63DC207771EABC6C6FFC22A7F455EC2209464897E",
    #     :type=>"send",
    #     :previous=>"FBF8B0E6623A31AB528EBD839EEAA91CAFD25C12294C46754E45FD017F7939EB",
    #     :destination=>"xrb_3x7cjioqahgs5ppheys6prpqtb4rdknked83chf97bot1unrbdkaux37t31b",
    #     :balance=>"00000000000000000000000000000000",
    #     :work=>"44cc24b60705083a",
    #     :signature=>"42ADFEFE7C3FFF188AE92A202F8A5734DE91779C454613E446EEC93D001D6C953E9FD16730AF32C891791BA8EDAECEB059A213E2FE1EEB7ADF9D5D0815464D06"
    #   }
    def info(allow_unchecked: false)
      if allow_unchecked
        # TODO not actually sure what this response looks like when it's not an unchecked block, assuming its blank
        response = rpc(:unchecked_get, :hash)
        if response[:error] != "Block not found"
          return _parse_info_response(response )
        end
        # Continue on falling backto checked block
      end

      response = rpc(:block, :hash)
      _parse_info_response(response)
    end

    # Returns boolean signalling if work is valid for the block.
    #
    #   block.is_valid_work?("2bf29ef00786a6bc") # => true
    def is_valid_work?(work)
      response = rpc(:work_validate, :hash, work: work)
      !response.empty? && response[:valid] == 1
    end

    # Republish blocks starting at this block up the account chain
    # back to the nano network.
    #
    # Returns an Array of block hashes that were republished.
    #
    # ==== Example
    #
    #   block.republish
    #
    # ==== Example response
    #   ["36A0FB717368BA8CF8D255B63DC207771EABC6C6FFC22A7F455EC2209464897E"]
    def republish(destinations:nil, sources:nil)
      if !destinations.nil? && !sources.nil?
        raise ArgumentError.new("You must provide either destinations or sources but not both")
      end

      # Add in optional arguments
      params = {}
      params[:destinations] = destinations unless destinations.nil?
      params[:sources] = sources unless sources.nil?
      params[:count] = 1 unless params.empty?

      rpc(:republish, :hash, params)[:blocks]
    end

    # Returns boolean +true+ if the block is a pending block.
    #
    #   block.pending? #=> false
    def pending?
      response = rpc(:pending_exists, :hash)
      !response.empty? && response[:exists] == 1
    end

    # Publish the block to the nano network.
    #
    # Note, if block has previously been published, use #republish instead.
    #
    # Returns the block hash, or false.
    #
    #   block.publish # => "FBF8B0E..."
    def publish
      # TODO I think this can return false or error or something?
      rpc(:process, :block)[:hash]
    end
    alias_method :process, :publish

    # Returns an Array of block hashes in the account chain ending at
    # this block.
    #
    # See also #chain.
    #
    # ==== Arguments
    #
    # [+limit:+] Maximum number of send/receive block hashes to return
    #            in the chain (default is 1000)
    #
    # ==== Example
    #
    #   block.successors
    #
    # ==== Example response
    #
    #   ["36A0FB717368BA8CF8D255B63DC207771EABC6C6FFC22A7F455EC2209464897E"]
    def successors(limit: 1000)
      response = rpc(:successors, :block, count: limit)[:blocks]
      Nanook::Util.coerce_empty_string_to_type(response, Array)
    end

    def inspect
      "#{self.class.name}(id: \"#{id}\", object_id: \"#{"0x00%x" % (object_id << 1)}\")"
    end

    private

    # Some RPC calls expect the param that represents the block to be named
    # "hash", and others "block".
    # The param_name argument allows us to specify which it should be for this call.
    def rpc(action, param_name, params={})
      p = @block.nil? ? {} : { param_name.to_sym => @block }
      @rpc.call(action, p.merge(params))
    end

    def block_required!
      if @block.nil?
        raise ArgumentError.new("Block must be present")
      end
    end

    def _parse_info_response(response)
      # The contents is a stringified JSON
      if response[:contents]
        r = JSON.parse(response[:contents]).to_symbolized_hash
        return r.merge(id: id)
      end

      response
    end

  end
end
