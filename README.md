<p align="center">
  <a href="http://gitron.herokuapp.com"><img src="http://i.imgur.com/6BG1Msb.png" alt="gitron logo" /></a>
</p>

# Gitron

>Greetings, programs!

## Description

This is a web game based on [TRON](http://en.wikipedia.org/wiki/Tron) universe. Every repository on GitHub can be a TRON character *(sam, clu, flynn, tron, etc.)* and may fight against other repositories.

The score is based on:

* number of commits
* repository size
* number of forks

**issues** instead will be subtracted to the main score of your repository.
The avatar is generated based on your repository **stars**, more stars it gets more important is the character generated :sunglasses:

Winner is chosen according to the higher score of the two programs fighting.

Beware the program who loses will be subject to immediate **deresolution**!

![sark](http://i.imgur.com/3llHbBR.gif)

## Achievements

These are just a few achievements you can unlock in **Gitron**.

Achievement | :sparkles:
----------- | -----
THE GRID | Enter The Grid 
FOUND ZUSE | Find a way to see Zuse *(the guy with the white hair)*
ISOMORPHIC | Discover and ISO
PURGE | Dereze an ISO
TRON LIVES | Is Tron still alive?
FAITH IN USERS | Dereze the poor Jarvis
BETRAYAL | When Clu 2 derezzed Tron
END OF LINE | Destroy Master Control Program
THE CREATOR | ???

![fight](http://i.imgur.com/q6kaw2f.gif)

## Installation

This app is written in Ruby using Sinatra.

```
gem install octokit
git clone git://github.com/syxanash/gitron
bundle install
ruby app.rb
```

## See also

Here listed a few things I used for developing this project.

* [github-high-scores](https://github.com/leereilly/github-high-scores) by Lee Reilly. I was highly inspired by his work.
* [Sinatra](http://www.sinatrarb.com/) a Ruby web framework
* [noty](https://github.com/needim/noty) jquery notification plugin
* [magic](https://github.com/miniMAC/magic) a couple of very nice CSS3 animations I used
* [github API](https://developer.github.com/v3/)

## Bugs & known issues

* Fetching the number of commits for a repo has a few problems, I need to get the number of commits without wasting too many [requests per hour](https://developer.github.com/v3/rate_limit/).
* __MCP__ apparently is still alive...

## Easter eggs

:rabbit:

* look up for the source code if you're interested

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## About

This is just a summer project I developed after finishing a few exams for university. I really hope you like it as much as I liked creating it!

Let's see if your programs are lucky enough to fight for his own user.

![clu2](http://media.giphy.com/media/IRSvFo1FIXuTK/giphy.gif)
