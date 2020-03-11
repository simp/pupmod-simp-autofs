# Single indirect file system mapping that can be specified in an
# autofs map file
#
# @example Indirect map without options
#   { 'key' => 'data', location => 'server.example.com:/exports/data' }
#
# @example Indirect map with options
#   { 'key' => '*', options => 'soft,rw', location => 'server.example.com:/exports/home/&' }
#
type Autofs::Indirectmapping = Struct[{
  key      => Pattern[/\A[^\s\/]+\z/],      # non empty string excluding /
  options  => Optional[Pattern[/\A\S+\z/]], # non empty string
  location => Pattern[/\S/]                 # contains at least 1 non-whitespace char
}]
