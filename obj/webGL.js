// Generated by CoffeeScript 1.4.0

/*1964js - JavaScript/HTML5 port of 1964 - N64 emulator
Copyright (C) 2012 Joel Middendorf

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/


(function() {
  var C1964jsWebGL, root;

  C1964jsWebGL = function(core, wireframe) {
    "use strict";
    this.gl = undefined;
    this.core = core;
    this.webGLStart(wireframe);
    return this;
  };

  (function() {
    "use strict";

    var mvMatrix, mvMatrixStack, nMatrix, pMatrix;
    nMatrix = void 0;
    pMatrix = void 0;
    mvMatrixStack = void 0;
    mvMatrix = mat4.create();
    mvMatrixStack = [];
    pMatrix = mat4.create();
    nMatrix = mat4.create();
    C1964jsWebGL.prototype.initGL = function(canvas) {
      try {
        log("canvas = " + canvas);
        log("canvas.getContext = " + canvas.getContext);
        this.gl = canvas.getContext("webgl") || canvas.getContext("moz-webgl") || canvas.getContext("webkit-3d") || canvas.getContext("experimental-webgl");
        log("gl = " + this.gl);
        this.gl.viewportWidth = canvas.width;
        log("this.gl.viewportWidth = " + this.gl.viewportWidth);
        this.gl.viewportHeight = canvas.height;
        log("this.gl.viewportHeight = " + this.gl.viewportHeight);
      } catch (_error) {}
      if (!this.gl) {
        log("Could not initialise WebGL. Your browser may not support it.");
      }
    };
    C1964jsWebGL.prototype.loadFile = function(url, data, callback, errorCallback) {
      var request;
      request = new XMLHttpRequest();
      request.open('GET', url, false);
      request.onreadystatechange = function() {
        if (request.readyState === 4) {
          if (request.status === 200) {
            callback(request.responseText, data);
          } else {
            errorCallback(url);
          }
        }
      };
      request.send(null);
    };
    C1964jsWebGL.prototype.loadFiles = function(urls, callback, errorCallback) {
      var i, numComplete, numUrls, partialCallback, result;
      numUrls = urls.length;
      numComplete = 0;
      result = [];
      partialCallback = function(text, urlIndex) {
        result[urlIndex] = text;
        numComplete += 1;
        if (numComplete === numUrls) {
          callback(result);
        }
      };
      i = 0;
      while (i < numUrls) {
        this.loadFile(urls[i], i, partialCallback, errorCallback);
        i++;
      }
    };
    C1964jsWebGL.prototype.initShaders = function(fs, vs) {
      var fragmentShader, shaderProgram, vertexShader,
        _this = this;
      shaderProgram = void 0;
      vertexShader = void 0;
      fragmentShader = void 0;
      this.loadFiles(['shaders/' + fs, 'shaders/' + vs], function(shaderText) {
        vertexShader = _this.gl.createShader(_this.gl.VERTEX_SHADER);
        fragmentShader = _this.gl.createShader(_this.gl.FRAGMENT_SHADER);
        _this.gl.shaderSource(fragmentShader, shaderText[0]);
        _this.gl.shaderSource(vertexShader, shaderText[1]);
        _this.gl.compileShader(fragmentShader);
        _this.gl.compileShader(vertexShader);
        if (!_this.gl.getShaderParameter(vertexShader, _this.gl.COMPILE_STATUS)) {
          alert(vs + ': ' + _this.gl.getShaderInfoLog(vertexShader));
        }
        if (!_this.gl.getShaderParameter(fragmentShader, _this.gl.COMPILE_STATUS)) {
          alert(_this.gl.getShaderInfoLog(fs + ' ' + fragmentShader));
        }
      }, function(url) {
        alert('Failed to download "' + url + '"');
      });
      shaderProgram = this.gl.createProgram();
      this.gl.attachShader(shaderProgram, vertexShader);
      this.gl.attachShader(shaderProgram, fragmentShader);
      this.gl.linkProgram(shaderProgram);
      if (!this.gl.getProgramParameter(shaderProgram, this.gl.LINK_STATUS)) {
        alert("Could not initialize shaders");
      }
      this.gl.useProgram(shaderProgram);
      shaderProgram.vertexPositionAttribute = this.gl.getAttribLocation(shaderProgram, "aVertexPosition");
      shaderProgram.vertexColorAttribute = this.gl.getAttribLocation(shaderProgram, "aVertexColor");
      shaderProgram.pMatrixUniform = this.gl.getUniformLocation(shaderProgram, "uPMatrix");
      shaderProgram.mvMatrixUniform = this.gl.getUniformLocation(shaderProgram, "uMVMatrix");
      shaderProgram.nMatrixUniform = this.gl.getUniformLocation(shaderProgram, "uNormalMatrix");
      shaderProgram.textureCoordAttribute = this.gl.getAttribLocation(shaderProgram, "aTextureCoord");
      shaderProgram.samplerUniform = this.gl.getUniformLocation(shaderProgram, "uSampler");
      shaderProgram.wireframeUniform = this.gl.getUniformLocation(shaderProgram, "uWireframe");
      shaderProgram.uCombineA0 = this.gl.getUniformLocation(shaderProgram, "uCombineA0");
      shaderProgram.uCombineB0 = this.gl.getUniformLocation(shaderProgram, "uCombineB0");
      shaderProgram.uCombineC0 = this.gl.getUniformLocation(shaderProgram, "uCombineC0");
      shaderProgram.uCombineD0 = this.gl.getUniformLocation(shaderProgram, "uCombineD0");
      shaderProgram.uCombineA0a = this.gl.getUniformLocation(shaderProgram, "uCombineA0a");
      shaderProgram.uCombineB0a = this.gl.getUniformLocation(shaderProgram, "uCombineB0a");
      shaderProgram.uCombineC0a = this.gl.getUniformLocation(shaderProgram, "uCombineC0a");
      shaderProgram.uCombineD0a = this.gl.getUniformLocation(shaderProgram, "uCombineD0a");
      shaderProgram.uCombineA1 = this.gl.getUniformLocation(shaderProgram, "uCombineA1");
      shaderProgram.uCombineB1 = this.gl.getUniformLocation(shaderProgram, "uCombineB1");
      shaderProgram.uCombineC1 = this.gl.getUniformLocation(shaderProgram, "uCombineC1");
      shaderProgram.uCombineD1 = this.gl.getUniformLocation(shaderProgram, "uCombineD1");
      shaderProgram.uCombineA1a = this.gl.getUniformLocation(shaderProgram, "uCombineA1a");
      shaderProgram.uCombineB1a = this.gl.getUniformLocation(shaderProgram, "uCombineB1a");
      shaderProgram.uCombineC1a = this.gl.getUniformLocation(shaderProgram, "uCombineC1a");
      shaderProgram.uCombineD1a = this.gl.getUniformLocation(shaderProgram, "uCombineD1a");
      shaderProgram.uPrimColor = this.gl.getUniformLocation(shaderProgram, "uPrimColor");
      shaderProgram.uFillColor = this.gl.getUniformLocation(shaderProgram, "uFillColor");
      shaderProgram.uEnvColor = this.gl.getUniformLocation(shaderProgram, "uEnvColor");
      shaderProgram.uBlendColor = this.gl.getUniformLocation(shaderProgram, "uBlendColor");
      shaderProgram.otherModeL = this.gl.getUniformLocation(shaderProgram, "otherModeL");
      shaderProgram.otherModeH = this.gl.getUniformLocation(shaderProgram, "otherModeH");
      return shaderProgram;
    };
    C1964jsWebGL.prototype.setCombineUniforms = function(shaderProgram) {
      var vhle;
      vhle = this.core.videoHLE;
      this.gl.uniform1i(shaderProgram.uCombineA0, vhle.combineA0);
      this.gl.uniform1i(shaderProgram.uCombineB0, vhle.combineB0);
      this.gl.uniform1i(shaderProgram.uCombineC0, vhle.combineC0);
      this.gl.uniform1i(shaderProgram.uCombineD0, vhle.combineD0);
      this.gl.uniform1i(shaderProgram.uCombineA0a, vhle.combineA0a);
      this.gl.uniform1i(shaderProgram.uCombineB0a, vhle.combineB0a);
      this.gl.uniform1i(shaderProgram.uCombineC0a, vhle.combineC0a);
      this.gl.uniform1i(shaderProgram.uCombineD0a, vhle.combineD0a);
      this.gl.uniform1i(shaderProgram.uCombineA1, vhle.combineA1);
      this.gl.uniform1i(shaderProgram.uCombineB1, vhle.combineB1);
      this.gl.uniform1i(shaderProgram.uCombineC1, vhle.combineC1);
      this.gl.uniform1i(shaderProgram.uCombineD1, vhle.combineD1);
      this.gl.uniform1i(shaderProgram.uCombineA1a, vhle.combineA1a);
      this.gl.uniform1i(shaderProgram.uCombineB1a, vhle.combineB1a);
      this.gl.uniform1i(shaderProgram.uCombineC1a, vhle.combineC1a);
      this.gl.uniform1i(shaderProgram.uCombineD1a, vhle.combineD1a);
    };
    C1964jsWebGL.prototype.beginDList = function() {
      this.gl.viewport(0, 0, this.gl.viewportWidth, this.gl.viewportHeight);
      this.gl.clear(this.gl.COLOR_BUFFER_BIT | this.gl.DEPTH_BUFFER_BIT);
      mat4.perspective(45, this.gl.viewportWidth / this.gl.viewportHeight, 0.1, 100.0, pMatrix);
      mat4.identity(mvMatrix);
      mat4.translate(mvMatrix, [0.0, 0.0, -2.4]);
      mat4.set(mvMatrix, nMatrix);
      mat4.inverse(nMatrix, nMatrix);
      mat4.transpose(nMatrix);
      mat4.translate(mvMatrix, [0.0, 0.0, -1.0]);
    };
    C1964jsWebGL.prototype.setMatrixUniforms = function(shaderProgram) {
      this.gl.uniformMatrix4fv(shaderProgram.pMatrixUniform, false, pMatrix);
      this.gl.uniformMatrix4fv(shaderProgram.mvMatrixUniform, false, mvMatrix);
      this.gl.uniformMatrix4fv(shaderProgram.nMatrixUniform, false, nMatrix);
    };
    C1964jsWebGL.prototype.mvPushMatrix = function() {
      var copy;
      copy = mat4.create();
      mat4.set(mvMatrix, copy);
      mvMatrixStack.push(copy);
    };
    C1964jsWebGL.prototype.mvPopMatrix = function() {
      if (mvMatrixStack.length === 0) {
        throw Error("Invalid popMatrix!");
      }
      mvMatrix = mvMatrixStack.pop();
    };
    C1964jsWebGL.prototype.webGLStart = function(wireframe) {
      var canvas;
      canvas = document.getElementById("Canvas3D");
      this.initGL(canvas);
      this.shaderProgram = this.initShaders("fragment.shader", "vertex.shader");
      if (this.gl) {
        this.gl.clearColor(0.0, 0.0, 0.0, 1.0);
      }
      canvas.style.visibility = "hidden";
    };
    C1964jsWebGL.prototype.show3D = function() {
      var canvas3D;
      canvas3D = document.getElementById("Canvas3D");
      canvas3D.style.visibility = "visible";
    };
    return C1964jsWebGL.prototype.hide3D = function() {
      var canvas3D;
      canvas3D = document.getElementById("Canvas3D");
      canvas3D.style.visibility = "hidden";
    };
  })();

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.C1964jsWebGL = C1964jsWebGL;

}).call(this);
