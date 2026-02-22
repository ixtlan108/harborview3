"use strict";

export const curTime = (_) => {
  const dx = new Date();
  const minutes = dx.getMinutes();
  const hours = dx.getHours();
  if (minutes < 10) {
    if (hours < 10) {
      return `0${hours}:0${minutes}`;
    } else {
      return `${hours}:0${minutes}`;
    }
  } else {
    if (hours < 10) {
      return `0${hours}:${minutes}`;
    } else {
      return `${hours}:${minutes}`;
    }
  }
};
