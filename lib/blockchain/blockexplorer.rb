require 'json'
require_relative 'util'

module Blockchain

	def self.get_block(block_id, api_code = nil)
		params = api_code.nil? ? { } : { 'api_code' => api_code }
		resource = 'rawblock/' + block_id
		response = Blockchain::call_api(resource, method: 'get', data: params)
		return Block.new(JSON.parse(response))
	end

	def self.get_tx(tx_id, api_code = nil)
		params = api_code.nil? ? { } : { 'api_code' => api_code }
		resource = 'rawtx/' + tx_id
		response = Blockchain::call_api(resource, method: 'get', data: params)
		return Transaction.new(JSON.parse(response))
	end

	def self.get_block_height(height, api_code = nil)
		params = { 'format' => 'json' }
		if !api_code.nil? then params['api_code'] = api_code end
		resource = "block-height/#{height}"
		response = Blockchain::call_api(resource, method: 'get', data: params)
		return JSON.parse(response)['blocks'].map{ |b| Block.new(b) }
	end

	def self.get_address(address, api_code = nil)
		params = api_code.nil? ? { } : { 'api_code' => api_code }
		resource = 'rawaddr/' + address
		response = Blockchain::call_api(resource, method: 'get', data: params)
		return Address.new(JSON.parse(response))
	end

	def self.get_unspent_outputs(address, api_code = nil)
		params = { 'active' => address }
		if !api_code.nil? then params['api_code'] = api_code end
		resource = 'unspent'
		response = Blockchain::call_api(resource, method: 'get', data: params)
		return JSON.parse(response)['unspent_outputs'].map{ |o| UnspentOutput.new(o) }
	end

	def self.get_unconfirmed_tx(api_code = nil)
		params = { 'format' => 'json' }
		if !api_code.nil? then params['api_code'] = api_code end
		resource = 'unconfirmed-transactions'
		response = Blockchain::call_api(resource, method: 'get', data: params)
		return JSON.parse(response)['txs'].map{ |t| Transaction.new(t) }
	end

	def self.get_blocks(api_code = nil, time: nil, pool_name: nil)
		params = { 'format' => 'json' }
		if !api_code.nil? then params['api_code'] = api_code end
		resource = "blocks/"
		if !time.nil?
			resource += time.to_s
		elsif !pool_name.nil?
			resource += pool_name
		end
		response = Blockchain::call_api(resource, method: 'get', data: params)
		return JSON.parse(response)['blocks'].map{ |b| SimpleBlock.new(b) }
	end
	
	def self.get_latest_block(api_code = nil)
		params = {}
		if !api_code.nil? then params['api_code'] = api_code end
		resource = 'latestblock'
		response = Blockchain::call_api(resource, method: 'get', data: params)
		return LatestBlock.new(JSON.parse(response))
	end
	
	def self.get_inventory_data(hash, api_code = nil)
		params = { 'format' => 'json' }
		if !api_code.nil? then params['api_code'] = api_code end
		resource = "inv/#{hash}"
		response = Blockchain::call_api(resource, method: 'get', data: params)
		return InventoryData.new(JSON.parse(response))
	end

	class SimpleBlock
		attr_reader :height
		attr_reader :hash
		attr_reader :time
		attr_reader :main_chain
		
		def initialize(b)
			@height = b['height']
			@hash = b['hash']
			@time = b['time']
			@main_chain = b['main_chain']
		end
	end

	class LatestBlock
		attr_reader :hash
		attr_reader :time
		attr_reader :block_index
		attr_reader :height
		attr_reader :tx_indexes
		
		def initialize(b)
			@hash = b['hash']
			@time = b['time']
			@block_index = b['block_index']
			@height = b['height']
			@tx_indexes = b['txIndexes']
		end
	end

	class UnspentOutput
		attr_reader :tx_hash
		attr_reader :tx_index
		attr_reader :tx_output_n
		attr_reader :script
		attr_reader :value
		attr_reader :value_hex
		attr_reader :confirmations
		
		def initialize(o)
			@tx_hash = o['tx_hash']
			@tx_index = o['tx_index']
			@tx_output_n = o['tx_output_n']
			@script = o['script']
			@value = o['value']
			@value_hex = o['value_hex']
			@confirmations = o['confirmations']
		end
	end

	class Address
		attr_reader :hash160
		attr_reader :address
		attr_reader :n_tx
		attr_reader :total_received
		attr_reader :total_sent
		attr_reader :final_balance
		attr_reader :transactions
		
		def initialize(a)
			@hash160 = a['hash160']
			@address = a['address']
			@n_tx = a['n_tx']
			@total_received = a['total_received']
			@total_sent = a['total_sent']
			@final_balance = a['final_balance']
			@transactions = a['txs'].map{ |tx| Transaction.new(tx) }
		end
	end

	class Input
		attr_reader :n
		attr_reader :value
		attr_reader :address
		attr_reader :tx_index
		attr_reader :type
		attr_reader :script
		attr_reader :script_sig
		attr_reader :sequence

		def initialize(i)
			obj = i['prev_out']
			if !obj.nil?
			# regular TX
				@n = obj['n']
				@value = obj['value']
				@address = obj['addr']
				@tx_index = obj['tx_index']
				@type = obj['type']
				@script = obj['script']
				@script_sig = i['script']
				@sequence = i['sequence']
			else
			# coinbase TX
				@script_sig = i['script']
				@sequence = i['sequence']
			end
		end
	end

	class Output
		attr_reader :n
		attr_reader :value
		attr_reader :address
		attr_reader :tx_index
		attr_reader :script
		attr_reader :spent

		def initialize(o)
			@n = o['n']
			@value = o['value']
			@address = o['addr']
			@tx_index = o['tx_index']
			@script = o['script']
			@spent = o['spent']
		end
	end

	class Transaction
		attr_reader :double_spend
		attr_reader :block_height
		attr_reader :time
		attr_reader :relayed_by
		attr_reader :hash
		attr_reader :tx_index
		attr_reader :version
		attr_reader :size
		attr_reader :inputs
		attr_reader :outputs
		
		def initialize(t)
			@double_spend = t.fetch('double_spend', false)
			@block_height = t.fetch('block_height', false)
			@time = t['time']
			@relayed_by = t['relayed_by']
			@hash = t['hash']
			@tx_index = t['tx_index']
			@version = t['ver']
			@size = t['size']
			@inputs = t['inputs'].map{ |i| Input.new(i) }
			@outputs = t['out'].map{ |o| Output.new(o) }
			
			if @block_height.nil?
				@block_height = -1
			end
		end
		
		def adjust_block_height(h)
			@block_height = h
		end
	end

		
	class Block
		attr_reader :hash
		attr_reader :version
		attr_reader :previous_block
		attr_reader :merkle_root
		attr_reader :time
		attr_reader :bits
		attr_reader :fee
		attr_reader :nonce
		attr_reader :n_tx
		attr_reader :size
		attr_reader :block_index
		attr_reader :main_chain
		attr_reader :height
		attr_reader :received_time
		attr_reader :relayed_by
		attr_reader :transactions
		
		def initialize(b)
			@hash = b['hash']
			@version = b['ver']
			@previous_block = b['prev_block']
			@merkle_root = b['mrkl_root']
			@time = b['time']
			@bits = b['bits']
			@fee = b['fee']
			@nonce = b['nonce']
			@n_tx = b['n_tx']
			@size = b['size']
			@block_index = b['block_index']
			@main_chain = b['main_chain']
			@height = b['height']
			@received_time = b['received_time']
			@relayed_by = b['relayed_by']
			@transactions = b['tx'].map{ |tx| Transaction.new(tx) }
			@transactions.each do |tx|
				tx.adjust_block_height(@height)
			end
			
			if @received_time.nil?
				@received_time = @time
			end
		end
	end

	class InventoryData
		attr_reader :hash
		attr_reader :type
		attr_reader :initial_time
		attr_reader :initial_ip
		attr_reader :nconnected
		attr_reader :relayed_count
		attr_reader :relayed_percent
			
		def initialize(i)
			@hash = i['hash']
			@type = i['type']
			@initial_time = i['initial_time'].to_i
			@initial_ip = i['initial_ip']
			@nconnected = i['nconnected'].to_i
			@relayed_count = i['relayed_count'].to_i
			@relayed_percent = i['relayed_percent'].to_i
		end
	end
		
end