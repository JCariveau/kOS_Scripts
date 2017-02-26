// Circularizer wrapper.
parameter iMultiplier is 1.
parameter iTarget is .005.

runoncepath("0:/lib_utils.ks").

cirE(iMultiplier, iTarget).

kNotify("Done").
