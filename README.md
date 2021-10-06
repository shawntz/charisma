# charisma v0.0.0.9000 [![Build Status](https://travis-ci.com/ShawnTylerSchwartz/charisma.svg?token=yxof8RQmkQy1mAwqs9Us&branch=main)](https://travis-ci.com/ShawnTylerSchwartz/charisma)

Hi @Development/Testing team, below are some quick instructions for loading up the development version of the `charisma` R package.

For testing purposes, you should be simulating loading in the package as if it were an installed package, and then calling individual functions via that package.

The first thing you'll want to make sure is that you have the `devtools` and `roxygen2` packages installed:

```{R}
install.packages("devtools")
install.packages("roxygen2")
```

Then, whenever you want to test/work with `charisma`, you should open the `charisma.Rproj` file via the `charisma` repo directory that you cloned from GitHub. This will open a new session in R exclusively isolated for `charisma`.

Once the session has opened, you can simulate "installing" and "loading in" the `charisma` development version of the package using the following command:
```{R}
devtools::load_all()
```

Now, the R environment should act like the package was just installed and loaded in. You should be able to access the `charisma` functions in the console/a demo script like this: `charisma::myFunctionName()`.

We still need to write the actual documentation for running the `charisma` pipeline/what each individual function does, however, I haven't done that yet since there might be considerable overhaul of the current core functions thus making any documentation written about the current functions obsolete. More updates to come. Happy testing, all!

--Shawn
