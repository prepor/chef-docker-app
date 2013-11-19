
actions :run #, :stop, :restart

default_action :run

attribute :id, :kind_of => String, :name_attribute => true
attribute :image, :kind_of => String, :required => true
attribute :cmd, :kind_of => Array
attribute :host, :kind_of => String
attribute :user, :kind_of => String
attribute :ports, :kind_of => Array
attribute :privileged, :kind_of => [TrueClass, FalseClass]
attribute :env, :kind_of => Array, :default => []
attribute :volumes, :kind_of => Array, :default => []
attribute :lxc_conf, :kind_of => Hash, :default => {}

attr_accessor :up_to_date, :running