#!/usr/bin/env ruby

# MDP ####################################################

states = [:s1, :s2, :s3, :s4, :s5]

actions = {
	:s1 => ['wait', 'move(r1,l1,l2)', 'move(r1,l1,l4)'],
	:s2 => ['wait', 'move(r1,l2,l1)', 'move(r1,l2,l3)'],
	:s3 => ['wait', 'move(r1,l3,l2)', 'move(r1,l3,l4)'],
	:s4 => ['wait', 'move(r1,l4,l1)', 'move(r1,l4,l3)', 'move(r1,l4,l5)'],
	:s5 => ['wait', 'move(r1,l5,l2)', 'move(r1,l5,l4)']
}

costs = {
	'wait' => 0,
	'move(r1,l1,l2)' => 100,
	'move(r1,l2,l1)' => 100,
	'move(r1,l1,l4)' => 1,
	'move(r1,l4,l1)' => 1,
	'move(r1,l2,l3)' => 1,
	'move(r1,l3,l2)' => 1,
	'move(r1,l3,l4)' => 100,
	'move(r1,l4,l3)' => 100,
	'move(r1,l4,l5)' => 100,
	'move(r1,l5,l4)' => 100,
	'move(r1,l5,l2)' => 1
}

rewards = {
	:s1 => 0, :s2 => 0, :s3 => 0, :s4 => 100, :s5 => -100
}

pr = {
	[:s1, 'move(r1,l1,l2)'] => {:s2 => 1.0},
	[:s1, 'move(r1,l1,l4)'] => {:s1 => 0.5, :s4 => 0.5},

	[:s2, 'move(r1,l2,l1)'] => {:s1 => 1.0},
	[:s2, 'move(r1,l2,l3)'] => {:s3 => 0.8, :s5 => 0.2},

	[:s3, 'move(r1,l3,l2)'] => {:s2 => 1.0},
	[:s3, 'move(r1,l3,l4)'] => {:s4 => 1.0},

	[:s4, 'move(r1,l4,l1)'] => {:s1 => 1.0},
	[:s4, 'move(r1,l4,l3)'] => {:s3 => 1.0},
	[:s4, 'move(r1,l4,l5)'] => {:s5 => 1.0},

	[:s5, 'move(r1,l5,l2)'] => {:s2 => 1.0},
	[:s5, 'move(r1,l5,l4)'] => {:s4 => 1.0}
}

gamma = 0.9


# VALUE ITERATION ########################################

epsilon = 0.001		# erro máximo

pi = []				# politica
v  = [{}]			# função valor

# inicializa V(s)
states.each do |s|
	v[0][s] = rewards[s]
end

n = 0 # contador de iterações

while 1
	n += 1

	v[n]  = {}
	pi[n] = {}

	error = {}

	states.each do |s|

		q_n = {}
		actions[s].each do |a|
			next_p = (pr[[s, a]] || {s => 1})
			
			sum = 0
			next_p.each do |s_prime, p|
				sum += p * v[n-1][s_prime]
			end

			q_n[[s,a]] = (rewards[s] - costs[a]) + gamma * sum
		end

		# max { Q(s,a) }
		v[n][s]  = q_n.values.max

		# argmax { Q(s,a) }
		pi[n][s] = q_n.select {|k, v| v == q_n.values.max}.keys[0][1]

		# erro iteração n para estado s
		error[s] = (v[n][s] - v[n-1][s]).abs
	end
	
	# condição de término
	if error.values.max < epsilon
		puts "Número de iterações = #{n}"
		puts

		puts ">> V(s)"
		v[n].each  {|s, v| puts "V(#{s})  = #{v}"}
		puts

		puts ">> pi(s)"
		pi[n].each {|s, a| puts "pi(#{s}) = #{a}"}

		break
	end
end