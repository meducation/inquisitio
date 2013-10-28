# Inquisitio

[![Build Status](https://travis-ci.org/meducation/inquisitio.png)](https://travis-ci.org/meducation/inquisitio)
[![Dependencies](https://gemnasium.com/meducation/inquisitio.png?travis)](https://gemnasium.com/meducation/inquisitio)
[![Code Climate](https://codeclimate.com/github/meducation/inquisitio.png)](https://codeclimate.com/github/meducation/inquisitio)

Inquisitio is a ruby wrapper around Amazon Cloud Search. It is currently under active development.

## Installation

Add this line to your application's Gemfile:

    gem 'inquisitio'

And then execute:

    $ bundle

## Usage

This gem allows you to build and execute queries to run against Amazon Cloud Search.

```
results = Inquisitio.where("foobar").per(10).page(2).with(facet: 'thingy')
results.each do |result|
  # ...
end
```

## Contributing

Firstly, thank you!! :heart::sparkling_heart::heart:

We'd love to have you involved. Please read our [contributing guide](https://github.com/meducation/inquisitio/tree/master/CONTRIBUTING.md) for information on how to get stuck in.

### Contributors

This project is managed by the [Meducation team](http://company.meducation.net/about#team). 

These individuals have come up with the ideas and written the code that made this possible:

- [Jeremy Walker](http://github.com/iHID)
- [Malcolm Landon](http://github.com/malcyL)
- [Charles Care](http://github.com/ccare)

## Licence

Copyright (C) 2013 New Media Education Ltd

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

A copy of the GNU Affero General Public License is available in [Licence.md](https://github.com/meducation/inquisitio/blob/master/LICENCE.md)
along with this program.  If not, see <http://www.gnu.org/licenses/>.
