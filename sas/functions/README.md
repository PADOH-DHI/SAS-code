# SAS-code: Functions

Package             | Description
------------------- | -----------
[Array](#array)     | General tools for handling arrays
[Date](#date)       | Validate, clean, and impute SAS date values
[Utility](#utility) | Miscellaneous tools (capitalization, filename dissection, etc.)

---

## Array package {#array}

---

### `identicalc`

Check if all values in a character array are equal.

#### Usage

`identicalc(char_array)`

#### Arguments

`char_array`

:   (character array) Array to check

#### Return

Numeric value: `1` if all values in `char_array` are equal, otherwise `0`. If less than two values are given, then `1` is returned.

#### Example

```sas
DATA _NULL_;
    Array myarray [3] $ ("dog" "dog" "dog");
    all_same = identicalc(myarray);
    Put all_same = "(should be 1)";
    
    myarray[2] = "cat";
    all_same = identicalc(myarray);
    Put all_same = "(should be 0)";
Run;
```

---

### `identicaln`

Check if all values in a numeric array are equal.

#### Usage

`identicaln(narray)`

#### Arguments

`narray`

:   (numeric array) Array to check

#### Return

Numeric value: `1` if all values in `narray` are equal, otherwise `0`. If less than two values are given, then `1` is returned.

#### Example

```sas
DATA _NULL_;
    Array myarray [3] (8 8 8);
    all_same = identicaln(myarray);
    Put all_same = "(should be 1)";
    
    myarray[2] = 7;
    all_same = identicaln(myarray);
    Put all_same = "(should be 0)";
Run;
```

---

### `reducec`

Collapse a character array to single value by cumulatively applying a binary function to its values, from left to right.

#### Usage

`reducec(function, carray)`

#### Arguments

`function`

:   (character value) Name of a function which takes two character values and returns a single character value.

`carray`

:   (character array) Array whose values will be collapsed.

#### Return

A character value as determined by the following steps:

1. Sex `x` as `carray[1]`.
2. For `i` from 2 to the length of `carray`, set `x` as `function(x, carray[i])`.
3. Return `x`.

#### Details

**Warning: this function should be considered experimental and not used in production code.**

This function implements the higher order function [fold](https://en.wikipedia.org/wiki/Fold_(higher-order_function)) in SAS.

#### Example

```sas
/* Removing key words from a sentence */
PROC FCMP outlib = Work.functions.example;
    Function redact(sentence $, word $) $;
        Return(tranwrd(sentence, word, "[SECRET]"));
    Endsub;
Run;

Options cmplib = Work.functions;

DATA _NULL_;
    Array myarray [3] $ 100 ("Jimmy walked his dog"
                             "Jimmy" "dog");
    cleaned = reducec("redact", myarray);
    Put cleaned = ;
Run;
```

---

### `reducen`

Collapse a numeric array to single value by cumulatively applying a binary function to its values, from left to right.

#### Usage

`reducen(function, narray)`

#### Arguments

`function`

:   (character value) Name of a function which takes two numeric values and returns a single numeric value.

`narray`

:   (numeric array) Array whose values will be collapsed

#### Return

A numeric value as determined by the following steps:

1. Sex `x` as `narray[1]`.
2. For `i` from 2 to the length of `narray`, set `x` as `function(x, narray[i])`.
3. Return `x`.

#### Details

**Warning: this function should be considered experimental and not used in production code.**

This function implements the higher order function [fold](https://en.wikipedia.org/wiki/Fold_(higher-order_function)) in SAS.

#### Example

```sas
/* Cumulative product */
PROC FCMP;
    Function multiply(x, y);
        Return(x * y);
    Endsub;
Run;

Options cmplib = Work.functions;

DATA _NULL_;
    Array myarray[4] (2 3 5 7);
    prod = reducen("multiply", myarray);
    Put prod = "(should be 210)";
Run;
```

---

### `sortn_dynamic`

Sort the values of any array.

#### Usage

`call sortn_dynamic(narray)`

#### Arguments

`narray`

:   (numeric array) Array to check

#### Return

The values of `narray` will be rearranged in ascending order.

#### Details

Base SAS comes with a CALL SORTN routine, but it doesn't work on dynamic arrays defined in a PROC FCMP routine. Call sortn_dynamic works on dynamic and non-dynamic arrays.

#### Example

```sas
PROC FCMP;
    Array myrand [3] (5.6 -2.5 1.7);
    Call sortn_dynamic(myrand);
    Put myrand = "(should be -2.5, 1.7, 5.6)";
Run;

/* Using the basic sortn raises an error */
PROC FCMP;
    Array myrand [3] (5.6 -2.5 1.7);
    Call sortn(myrand);
Run;
```

---
