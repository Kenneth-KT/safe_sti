# Safe STI
This Gem makes ActiveRecord's STI (Single Table Inheritance) feature play nice with eager loading by enforcing the developers to write out direct STI child classes and automatically eager load the entire STI hierarchy whenever a STI class is loaded, to prevent inconsistent behavior in queries.

Learn more about the problems of using Autoloading + STI:
https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#single-table-inheritance

## Usage
Let say you have the following class hierarchy:

`Cat < Animal < Thing < ApplicationRecord`

`Dog < Animal < Thing < ApplicationRecord`

First, install this gem and enable Safe STI checking for `ApplicationRecord`:
`app/models/appliaction_record.rb`:
```
 class ApplicationRecord
   self.abstract_class = true
+  SafeSti.enable_for self
   ...<your code>...
 end
```

In STI models, declare the list of direct subclasses with `safe_sti_child { <KLASS> }` format:
`app/models/thing.rb`:
```
 class Thing < AppliactionRecord
+  safe_sti_child { Animal }
  ...<your code>...
 end
```
`app/models/animal.rb`:
```
 class Animal < Thing
+  safe_sti_child { Cat }
+  safe_sti_child { Dog }
  ...<your code>...
 end
```
 or
```
 class Animal < Thing
+  safe_sti_child { [Cat, Dog] }
  ...<your code>...
 end
```

Then you can try to add a new subclass without definiting it using `safe_sti_child`.
`app/models/unicorn.rb`:
```
+class Unicorn < Animal
+end
```
In your console, run:
`Unicorn.new` or `Unicorn.find(1)`
will result in warning being emitted as follow:
```
Missing `safe_sti_child { Unicorn }` inside class body of Animal class
```
The developer will need to follow the instruction provided to eliminate the warning:
`app/models/animal.rb`:
```
 class Animal < Thing
   safe_sti_child { Cat }
   safe_sti_child { Dog }
+  safe_sti_child { Unicorn }
   ...<your code>...
 end
```
In this way, your STI model hierarchy will always be full loaded, preventing the inconsistent query result caused by lazy class loading.