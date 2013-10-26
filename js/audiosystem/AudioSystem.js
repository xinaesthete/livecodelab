/*jslint browser: true */
/*global AudioContext, $ */

(function (w) {

    var LCLSoundSystem, soundprocess, sound, scriptNode, context, config;

    config = {
        buffersize: 2048
    };

    $(document).ready(function () {
        sound = function (e) {

            var i, data;
            data = e.outputBuffer.getChannelData(0);

            for (i = 0; i < data.length; i += 1) {
                data[i] = 0;
            }

        };

        context = new AudioContext();
        scriptNode = context.createJavaScriptNode(config.buffersize, 0, 1);

        scriptNode.connect(context.destination);
        scriptNode.onaudioprocess = function (e) {
            sound(e);
        };
    });

    w.LCLSoundSystem = LCLSoundSystem = function () {
        w.oscillator = this.oscillator;
        w.mix = this.mix;
        w.gain = this.gain;
        w.filter = this.filter;
        w.out = this.out;
    };

    // arguments
    // node:    The node that will have it's output sent to the DAC
    //
    // returns
    // null
    LCLSoundSystem.prototype.out = function (node) {

        sound = function (e) {

            var i, data, output;
            data = e.outputBuffer.getChannelData(0);

            output = node(data.length);

            for (i = 0; i < data.length; i += 1) {
                data[i] = output[i];
            }

        };

    };

    // arguments
    // freq:    The frequency of the oscillator
    // returns
    // The audio generation function
    LCLSoundSystem.prototype.oscillator = function (freq) {

        return function (samplenum) {
            var i, audio;

            audio = [];

            for (i = 0; i < samplenum; i += 1) {
                audio[i] = (i / samplenum);
            }

            return audio;
        };
    };

    // arguments
    // input:   The audio node to filter
    // returns
    // The audio generation function
    LCLSoundSystem.prototype.filter = function (input) {
        var lastsample;
        lastsample = 0;

        return function (samplenum) {
            var i, inputdata, audio;
            inputdata = input(samplenum);
            audio = [];
            for (i = 0; i < samplenum; i += 1) {
                audio[i] = (inputdata[i] + lastsample) / 2;
                lastsample = inputdata[i];
            }
            return audio;
        };
    };

    // arguments
    // input:   The audio node to filter
    // returns
    // The audio generation function
    LCLSoundSystem.prototype.mix = function () {
        var argum;
        argum = arguments

        return function (samplenum) {
            var i, inputdata, audio, argumentsLength;

            inputdata = [];
            argumentsLength  = argum.length;
            for (var k = 0; k < argumentsLength; k++){
                inputdata[k] =  (argum[k])(samplenum);
            }

            // it's could be more efficient to have the
            // longest loop inside rather than inside.
            // that said, inverting the loops means that one
            // needs to initialise the whole audio array with
            // zeroes, so that could outweight the benefit.
            // (although it seems that doing += of an undefined
            // element of an array is actually OK...)
            audio = [];
            for (i = 0; i < samplenum; i += 1) {
                audio[i] = 0;
                for (var m = 0; m < argumentsLength; m++){
                    audio[i] +=  inputdata[m][i];
                }
            }
            return audio;
        };
    };

    // arguments
    // gain:    The value to multiply the audio by
    // input:   The input audio node
    // returns
    // The audio generation function
    LCLSoundSystem.prototype.gain = function (gain, node) {

        return function (samplenum) {
            var i, inputdata, audio;
            inputdata = node(samplenum);
            audio = [];
            for (i = 0; i < samplenum; i += 1) {
                audio[i] = inputdata[i] * gain;
            }
            return audio;
        };
    };

}(window));

