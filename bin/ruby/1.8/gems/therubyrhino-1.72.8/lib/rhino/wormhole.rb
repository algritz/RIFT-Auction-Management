
module Rhino
  module To        
    JS_UNDEF = [J::Scriptable::NOT_FOUND, J::Undefined]
    
    def ruby(object)
      case object
      when *JS_UNDEF                then nil
      when J::Wrapper               then object.unwrap
      when J::NativeArray           then array(object)
      when J::Regexp::NativeRegExp  then object
      when J::Function              then NativeFunction.new(object)
      when J::Scriptable            then NativeObject.new(object)
      else  object
      end        
    end
    
    def javascript(object)
      case object
      when String,Numeric       then object
      when TrueClass,FalseClass then object
      when Array                then J::NativeArray.new(object.to_java)
      when Hash                 then ruby_hash_to_native(object)
      when Proc,Method          then RubyFunction.new(object)
      when NativeObject         then object.j      
      when J::Scriptable        then object
      else RubyObject.new(object)
      end
    end
    
    def array(native)
      native.length.times.map {|i| ruby(native.get(i,native))}
    end

    def ruby_hash_to_native(ruby_object)
      native_object = NativeObject.new

      ruby_object.each_pair do |k, v|
        native_object[k] = v
      end

      native_object.j
		end
    
    module_function :ruby, :javascript, :array, :ruby_hash_to_native
  end
end
