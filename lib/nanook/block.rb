class Nanook

  # The <tt>Nanook::Block</tt> class contains methods to discover
  # publicly-available information about blocks on the nano network.
  #
  # A block is represented by a unique hash
  #
  # Initialize this class through the convenient Nanook#block method:
  #
  #   nanook = Nanook.new
  #   account = nanook.block("991CF19...")
  #
  # Or compose the longhand way like this:
  #
  #   rpc_conn = Nanook::Rpc.new
  #   block = Nanook::Block.new(rpc_conn, "991CF19...")
  class Block

    def initialize(rpc, block)
      @rpc = rpc
      @block = block
      block_required! # All methods expect a block
    end

    def account
      rpc(:block_account, :hash)[:account]
    end

    def cancel_work
      rpc(:work_cancel, :hash).empty?
    end

    def chain(limit: 1000)
      response = rpc(:chain, :block, count: limit)[:blocks]
      Nanook::Util.coerce_empty_string_to_type(response, Array)
    end

    def generate_work
      rpc(:work_generate, :hash)[:work]
    end

    def history(limit: 1000)
      rpc(:history, :hash, count: limit)[:history]
    end

    def id
      @block
    end

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

    def is_valid_work?(work)
      response = rpc(:work_validate, :hash, work: work)
      !response.empty? && response[:valid] == 1
    end

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

    def pending?
      response = rpc(:pending_exists, :hash)
      !response.empty? && response[:exists] == 1
    end

    def process
      rpc(:process, :block)[:hash]
    end

    def successors(limit: 1000)
      response = rpc(:successors, :block, count: limit)[:blocks]
      Nanook::Util.coerce_empty_string_to_type(response, Array)
    end

    def inspect # :nodoc:
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
        return JSON.parse(response[:contents]).to_symbolized_hash
      end

      response
    end

  end
end
