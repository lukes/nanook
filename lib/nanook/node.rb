# frozen_string_literal: true

class Nanook
  # The <tt>Nanook::Node</tt> class contains methods to manage your nano
  # node and query its data of the nano network.
  #
  # Your node is constantly syncing data with other nodes on the network. When
  # your node first starts up after being built, its database will be empty
  # and it will begin synchronizing and downloading data of the nano ledger
  # to its local database. The ledger is the central record of all accounts
  # and transactions. Some of the methods in this class query your node's
  # database formed from the nano ledger, and so the responses are determined
  # by the completeness of your node's database.
  #
  # You can determine how synchronized your node is with the nano ledger
  # with the {#sync_progress} method.
  #
  # === Initializing
  #
  # Initialize this class through the convenient {Nanook#node} method:
  #
  #   node = Nanook.new.node
  #
  # Or compose the longhand way like this:
  #
  #   rpc_conn = Nanook::Rpc.new
  #   node = Nanook::Node.new(rpc_conn)
  class Node
    def initialize(rpc)
      @rpc = rpc
    end

    # The number of accounts in the nano ledger--essentially all
    # accounts with _open_ blocks. An _open_ block
    # is the type of block written to the nano ledger when an account
    # receives its first payment (see {Nanook::WalletAccount#receive}). All accounts
    # that respond +true+ to {Nanook::Account#exists?} have open blocks in the ledger.
    #
    # @return [Integer] number of accounts with _open_ blocks.
    def account_count
      rpc(:frontier_count)[:count]
    end
    alias frontier_count account_count

    # The count of all blocks downloaded to the node, and
    # blocks still to be synchronized by the node.
    #
    # ==== Example:
    #
    #
    #
    # @return [Hash{Symbol=>Integer}] number of blocks and unchecked
    #   synchronizing blocks
    def block_count
      rpc(:block_count)
    end

    # Initialize bootstrap to a specific IP address and port.
    #
    # @return [Boolean] indicating if the action was successful
    def bootstrap(address:, port:)
      rpc(:bootstrap, address: address, port: port).key?(:success)
    end

    # Initialize multi-connection bootstrap to random peers
    #
    # @return [Boolean] indicating if the action was successful
    def bootstrap_any
      rpc(:bootstrap_any).key?(:success)
    end

    # Initialize lazy bootstrap with given block hash
    #
    # @param hash [String]
    # @param force [Boolean] False by default. Manually force closing
    #   of all current bootstraps
    # @return [Boolean] indicating if the action was successful
    def bootstrap_lazy(hash, force: false)
      rpc(:bootstrap_lazy, hash: hash, force: force)[:started] == 1
    end

    # Returns information about node elections settings and observed network state:
    #
    # - `quorum_delta`: delta tally required to rollback block
    # - `online_weight_quorum_percent`: percentage of online weight for delta
    # - `online_weight_minimum`: minimum online weight to confirm block
    # - `online_stake_total`: currently observed online total weight
    # - `peers_stake_total`: known peers total weight
    # - `peers_stake_required`: effective stake needed from directly connected peers for quorum
    #
    # ==== Example:
    #
    #   node.confirmation_quorum
    #
    # Example response:
    #
    #   {
    #     "quorum_delta": "41469707173777717318245825935516662250",
    #     "online_weight_quorum_percent": "50",
    #     "online_weight_minimum": "60000000000000000000000000000000000000",
    #     "online_stake_total": "82939414347555434636491651871033324568",
    #     "peers_stake_total": "69026910610720098597176027400951402360",
    #     "peers_stake_required": "60000000000000000000000000000000000000"
    #   }
    #
    # @return [Hash{Symbol=>String|Integer}]
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def confirmation_quorum(unit: Nanook.default_unit)
      Nanook.validate_unit!(unit)

      response = rpc(:confirmation_quorum)
      response = Nanook::Util.coerce_empty_string_to_type(response, Hash)

      return response unless unit == :nano

      response[:quorum_delta] = Nanook::Util.raw_to_NANO(response[:quorum_delta])
      response[:online_weight_minimum] = Nanook::Util.raw_to_NANO(response[:online_weight_minimum])
      response[:online_stake_total] = Nanook::Util.raw_to_NANO(response[:online_stake_total])
      response[:peers_stake_total] = Nanook::Util.raw_to_NANO(response[:peers_stake_total])
      response[:peers_stake_required] = Nanook::Util.raw_to_NANO(response[:peers_stake_required])

      response.compact
    end

    # Returns the difficulty values (16 hexadecimal digits string, 64 bit)
    # for the minimum required on the network (network_minimum) as well
    # as the current active difficulty seen on the network (network_current,
    # 5 minute trended average of adjusted difficulty seen on confirmed
    # transactions) which can be used to perform rework for better
    # prioritization of transaction processing. A multiplier of the
    # network_current from the base difficulty of network_minimum is also
    # provided for comparison.
    #
    # ==== Example:
    #
    #   node.difficulty(include_trend: true)
    #
    # Example response:
    #
    #   {
    #     network_minimum: "ffffffc000000000",
    #     network_current: "ffffffc1816766f2",
    #     multiplier: 1.024089858417128,
    #     difficulty_trend: [
    #       1.156096135149775,
    #       1.190133894573061,
    #       1.135567138563921,
    #       1.000000000000000,
    #     ]
    #   }
    #
    # @param include_trend [Boolean] false by default. Also returns the
    #   trend of difficulty seen on the network as a list of multipliers.
    #   Sampling occurs every 16 to 36 seconds. The list is ordered such
    #   that the first value is the most recent sample.
    # @return [Hash{Symbol=>String|Float|Array}]
    def difficulty(include_trend: false)
      rpc(:active_difficulty, include_trend: include_trend).tap do |response|
        response[:multiplier] = response[:multiplier].to_f

        response[:difficulty_trend].map!(&:to_f) if response.key?(:difficulty_trend)
      end
    end

    # @return [String]
    def inspect
      "#{self.class.name}(object_id: \"#{format('0x00%x', (object_id << 1))}\")"
    end

    # Returns a list of pairs of online peer IPv6:port and its node protocol
    # network version.
    #
    # Example response:
    #
    #   {
    #     :"[::ffff:104.131.102.132]:7075"=>18,
    #     :"[::ffff:104.131.114.102]:7075"=>18
    #   }
    #
    # @return [Hash{String=>Integer}]
    def peers
      rpc(:peers)[:peers]
    end

    # All representatives and their voting weight.
    #
    # ==== Example:
    #
    #   node.representatives
    #
    # Example response:
    #
    #   {
    #     nano_1111111111111111111111111111111111111111111111111117353trpda: 3822372327060170000000000000000000000,
    #     nano_1111111111111111111111111111111111111111111111111awsq94gtecn: 30999999999999999999999999000000,
    #     nano_114nk4rwjctu6n6tr6g6ps61g1w3hdpjxfas4xj1tq6i8jyomc5d858xr1xi: 0
    #   }
    #
    # @return [Hash{Symbol=>Integer}] known representatives and their voting weight
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def representatives(unit: Nanook.default_unit)
      Nanook.validate_unit!(unit)

      response = rpc(:representatives)[:representatives]
      return response if unit == :raw

      r = response.map do |account_id, balance|
        balance = Nanook::Util.raw_to_NANO(balance)

        [account_id, balance]
      end

      Hash[r].to_symbolized_hash
    end

    # All online representatives that have voted recently. Note, due to the
    # design of the nano RPC, this method cannot return the voting weight
    # of the representatives.
    #
    # ==== Example:
    #
    #   node.representatives_online # => ["nano_111...", "nano_222"]
    #
    # @return [Array<String>] array of representative account ids
    def representatives_online
      rpc(:representatives_online)[:representatives].map(&:to_s)
    end

    # Safely shuts down the node.
    #
    # @return [Boolean] indicating if action was successful
    def stop
      rpc(:stop).key?(:success)
    end

    # @param limit [Integer] number of synchronizing blocks to return
    # @return [Hash{Symbol=>String}] information about the synchronizing blocks for this node
    def synchronizing_blocks(limit: 1000)
      response = rpc(:unchecked, count: limit)[:blocks]
      response = response.map do |block, info|
        [block, JSON.parse(info).to_symbolized_hash]
      end
      Hash[response.sort].to_symbolized_hash
    end
    alias unchecked synchronizing_blocks

    # The percentage completeness of the synchronization process for
    # your node as it downloads the nano ledger. Note, it's normal for
    # your progress to not ever reach 100. The closer to 100, the more
    # complete your node's data is, and so the query methods in this class
    # become more reliable.
    #
    # @return [Float] the percentage completeness of the synchronization
    #   process for your node
    def sync_progress
      response = rpc(:block_count)

      count = response[:count]
      unchecked = response[:unchecked]
      total = count + unchecked

      count.to_f * 100 / total.to_f
    end

    # Returns node uptime in seconds
    #
    # @return [Integer] seconds of uptime
    def uptime
      rpc(:uptime)['seconds']
    end

    # This method is deprecated and will be removed in 3.0, as a node never
    # reaches 100% synchronization.
    #
    # @return [Boolean] signalling if this node ever reaches 100% synchronized
    def synced?
      warn '[DEPRECATION] `synced?` is deprecated and will be removed in 3.0'
      (rpc(:block_count)[:unchecked]).zero?
    end

    # @return [Hash{Symbol=>Integer|String}] version information for this node
    def version
      rpc(:version)
    end
    alias info version

    private

    def rpc(action, params = {})
      @rpc.call(action, params)
    end
  end
end
