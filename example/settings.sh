# Number of operations in a batch.
#
batch_size=65536

# Duration of the experiment (in seconds).
#    5 seconds warmup
#   20 seconds stable
#    5 seconds teardown
#
duration=$(( 5 + 20 + 5 ))

# Estimation of the network latency.
# Used by workload generator.
#
latency_estimate=6

# Number of operation per second for each load broker.
#
load_broker_ops=70000

# Number of operation per second for each load client.
#
load_client_ops=3000

# How much batches are reduced by load brokers.
# 0.0 = no reduction
# 1.0 = full reduction
#
reduction_probability=1.0

# Application executed by servers.
#   random
#   payment
#   auction
#   pixel
#
application='random'

# Atomic Broadcast used internally.
#   bftsmart
#   hotstuff
#
tobcast='bftsmart'

# Number of request per batch in the Atomic Broadcast
#
batch=400

# How many servers ignored by GC.
#
gc_exclude=0

# How many expected stragglers.
#
margin=0
