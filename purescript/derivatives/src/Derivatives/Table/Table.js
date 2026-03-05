"use strict";

/*
export const setTableItemSelected = (item) => (isSelected) => {
  return function () {
    item.selected = isSelected;
  };
};
*/

export const setSelected_ = (item, isSelected) => {
  return function () {
    item.selected = isSelected;
  };
};

export const setRisc_ = (item, risc) => {
  return function () {
    item.risc = risc;
  };
};

export const setCalcRiscResult_ = (item, sp) => {
  return function () {
    item.spAtRisc = sp;
  };
};
