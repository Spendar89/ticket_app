@section_1 = 5
 @section_2 = 10
 @section_5 = 25
 @section_7 = 30
 @section_8 = 30
 @section_10 = 25
 @section_13 = 5
 @section_14 = 0
 @section_15 = 0
 @section_16 = 5
 @section_19 = 25
 @section_21 = 30
 @section_22 = 30
 @section_24 = 25
 @section_27 = 10
 @section_28 = 5

 @section_113 = 60 + @section_13
 @section_114 = 60 + @section_14
 @section_115 = 60 + @section_15
 @section_116 = 60 + @section_16
 @section_117 = 60 + @section_19
 @section_118 = 60 + @section_19
 @section_119 = 60 + @section_19
 @section_120 = 60 + @section_21
 @section_121 = 60 + @section_21
 @section_122 = 60 + @section_22
 @section_123 = @section_120
 @section_124 = @section_119
 @section_125 = @section_118
 @section_126 = @section_117
 @section_127 = 60 + @section_27
 @section_128 = 60 + @section_28
 @section_101 = 60 + @section_1
 @section_102 = 60 + @section_2
 @section_103 = @section_117
 @section_104 = @section_118
 @section_105 = @section_119
 @section_106 = @section_120
 @section_107 = @section_122
 @section_108 = @section_121
 @section_109 = @section_123
 @section_110 = @section_124
 @section_111 = @section_118
 @section_112 = @section_117
 @sectiom_201 = @section_216
 @section_214 = @section_111 + 120
 @section_215 = @section_113 + 120
 @section_216 = @section_114 + 120
 @section_217 = @section_115 + 120
 @section_218 = @section_116 + 120
 @section_219 = @section_214
 @section_220 = @section_118 + 120
 @section_221 = @section_119 + 120
 @section_222 = @section_120 + 120
 @section_223 = @section_222
 @section_224 = @section_222
 @section_225 = @section_224
 @section_226 = @section_223
 @section_227 = @section_222
 @section_228 = @section_221
 @section_229 = @section_220
 @section_230 = @section_219
 @section_231 = @section_218
 @section_232 = @section_217
 @section_202 = @section_215
 @section_203 = @section_214
 @section_204 = @section_220
 @section_205 = @section_221
 @section_206 = @section_222
 @section_207 = @section_226
 @section_208 = @section_225
 @section_209 = @section_224
 @section_210 = @section_223
 @section_211 = @section_222
 @section_212 = @section_221
 @section_213 = @section_220

$oracle_arena_hash = {}
240.times do |i|
  $oracle_arena_hash.merge!({i.to_s=>instance_variable_get('@section_' + "#{i}")}) unless instance_variable_get('@section_' + "#{i}").nil?
end

$oracle_arena_hash = $oracle_arena_hash.merge!({"201"=>180})
# puts $oracle_arena_hash
# average = $oracle_arena_hash.values.inject(0){|x, y| x +y}/$oracle_arena_hash.values.length
# variance = []
# $oracle_arena_hash.values.each do |value|
#   variance << (((100 - value) - (100 -average))**2)
# end
#
# variance = variance.inject(0){|x, y| x+y }
# standard_deviation = Math.sqrt(variance/(100-average))
#
# puts standard_deviation
# puts average


