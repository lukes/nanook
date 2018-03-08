class Nanook
  class Block

    def initialize(block, rpc)
      @block = block
      @rpc = rpc
      block_required! # All methods expect a block
    end

    def account
      rpc(:block_account, :hash)
    end

    def cancel_work
      rpc(:work_cancel, :hash)
    end

    def chain(limit: 1000)
      rpc(:chain, :block, count: limit)
    end

    def generate_work
      rpc(:work_generate, :hash)
    end

    def history(limit: 1000)
      rpc(:history, :hash, count: limit)
    end

    def info(allow_unchecked: false)
      if allow_unchecked
        # TODO not actually sure what this response looks like when it's not an unchecked block, assuming its blank
        response = rpc(:unchecked_get, :hash)
        return response unless response[:error] == "Block not found"
        # Continue on falling backto checked block
      end

      response = rpc(:block, :hash)

      # The contents is a stringified JSON
      if response[:contents]
        response[:contents] = JSON.parse(response[:contents])
      end

      response
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

      rpc(:republish, :hash, params)
    end

    def pending?
      response = rpc(:pending_exists, :hash)
      !response.empty? && response[:exists] == 1
    end

    def process
      rpc(:process, :block)
    end

    def successors(limit: 1000)
      rpc(:successors, :block, count: limit)
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

  end
end
