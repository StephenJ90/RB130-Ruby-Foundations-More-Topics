# The following list contains the names of individuals who are pioneers in 
# the field of computing or that have had a significant influence on the field.
# The names are in an encrypted form, though, using a simple 
# (and incredibly weak) form of encryption called Rot13.

# input: strings
# output: string

# mental model:
# each character in the name has to be replaced with the letter from the
# the alphabet that is 13 indexes ahead of it. 'A' is index 0. 'Z' is 25.
# 'N' is 13. So 'N' and any letters after it will have to wrap back to the
# beginning of the alphabet.

# Algorithm:
# find the index of each letter accoring to the alphabet
# add 13 to the that index to find the index of the letter that will replace
# the current letter
# if that index is 26 or greater, subtract 26
# use this new number as the index to retrieve the letter from the alphabet
# that corresponds to that index

ENCRYPTED_PIONEERS = [
  'Nqn Ybirynpr',
  'Tenpr Ubccre',
  'Nqryr Tbyqfgvar',
  'Nyna Ghevat',
  'Puneyrf Onoontr',
  'Noqhyynu Zhunzznq ova Zhfn ny-Xujnevmzv',
  'Wbua Ngnanfbss',
  'Ybvf Unvog',
  'Pynhqr Funaaba',
  'Fgrir Wbof',
  'Ovyy Tngrf',
  'Gvz Orearef-Yrr',
  'Fgrir Jbmavnx',
  'Xbaenq Mhfr',
  'Fve Nagbal Ubner',
  'Zneiva Zvafxl',
  'Lhxvuveb Zngfhzbgb',
  'Unllvz Fybavzfxv',
  'Tregehqr Oynapu'
].freeze

UPPER = ('A'..'Z').to_a
LOWER = ('a'..'z').to_a

def decipher(string)
  result = ''

  string.chars.each_with_index do |char, idx|
    if UPPER.include?(char)
      index = UPPER.index(char) + 13
      index -= 26 if index > 25
      result += UPPER[index]
    elsif LOWER.include?(char)
      index = LOWER.index(char) + 13
      index -= 26 if index > 25
      result += LOWER[index]
    else
      result += ' '
    end
  end
  result
end

def rot13
  ENCRYPTED_PIONEERS.each do |name|
    puts decipher(name)
  end
end

rot13
