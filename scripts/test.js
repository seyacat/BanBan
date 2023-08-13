const global = this;
let update;
let _timelapse_data;
const _timelapse = () => {
  _timelapse_data = arguments;
  update = (context) => {
    if (_timelapse_data.length) {
      _timelapse_data[0][2] = (_timelapse_data[0]?.[2] ?? 1000) - context.delta;
      if (_timelapse_data[0][2] <= 0) {
        action = _timelapse_data.shift();
        this[action[0]] = action[1];
      }
    }
  };
};
