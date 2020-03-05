# Single direct file system mapping that can be specified in an
# autofs map file
#
# @example Direct map without options
#   { 'key' => '/mnt/apps', location => 'server.example.com:/exports/apps' }
#
# @example Direct map with options
#   { 'key' => '/mnt/apps', options => 'nfsvers=4,ro', location => 'server.example.com:/exports/apps' }
#
#
type Autofs::Directmapping = Struct[{
  key      => Stdlib::Absolutepath,
  options  => Optional[Pattern[/\A\S+\z/]], # non empty string
  location => Pattern[/\S/]                 # contains at least 1 non-whitespace char
}]
