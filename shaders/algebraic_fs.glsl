precision highp float;

      const float PI = 3.1415926535897932384626433832795;
      const float E = 2.7182818284590452353602874713527;
      const vec2 pi = vec2(PI, 0.0);
      const vec2 e = vec2(E, 0.0);
      const vec2 i = vec2(0.0, 1.0);
      const vec2 c_nan = vec2(10000.0, 20000.0);

      bool error;

      #define c_abs(a) length(a)

      vec2 c_mul(vec2 a, vec2 b)
      {
          return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x);
      }

      vec2 c_div(vec2 a, vec2 b)
      {
          float denominator = dot(b,b);
          if (denominator == 0.0) {
              error = true;
              return c_nan;
          }
          return vec2(dot(a,b) / denominator, (a.y*b.x - a.x*b.y) / denominator);
      }

      float c_arg(vec2 a)
      {
          if (a.x == 0.0 && a.y == 0.0) {
              error = true;
          }
          return atan(a.y, a.x);
      }

      vec2 c_exp(vec2 z)
      {
          return vec2(exp(z.x)*cos(z.y), exp(z.x)*sin(z.y));
      }

      vec2 c_pow(vec2 z, vec2 w)
      {
          /*
          z = r*e^(i*t)
          w = c+di
          z^w = r^c * e^(-d*t) * e^(i*c*t + i*d*log(r))
          */

          float r = c_abs(z);
          float theta = c_arg(z);

          float r_ = pow(r, w.x);
          float theta_ = theta * w.x;

          if (w.y != 0.0)
          {
              r_ *= exp(-w.y*theta);
              theta_ += w.y*log(r);
          }

          return vec2(r_*cos(theta_), r_*sin(theta_));
      }

      vec2 c_sqrt(vec2 z)
      {
          float r = c_abs(z);

          float a = sqrt((r + z.x)/2.0);
          float b = sqrt((r - z.x)/2.0);

          if (z.y < 0.0)
            b = -b;

          return vec2(a, b);
      }

      vec2 c_inv(vec2 z)
      {
          return c_div(vec2(1.0, 0), z);
      }

      vec2 c_log(vec2 z)
      {
          return vec2(log(c_abs(z)), c_arg(z));
      }

      float cosh(float x)
      {
          float e = exp(x);
          return 0.5 * (e + 1.0/e);
      }

      float sinh(float x)
      {
          float e = exp(x);
          return 0.5 * (e - 1.0/e);
      }

      vec2 c_sin(vec2 z)
      {
          return vec2(sin(z.x) * cosh(z.y), cos(z.x) * sinh(z.y));
      }

      vec2 c_cos(vec2 z)
      {
          return vec2(cos(z.x) * cosh(z.y), -sin(z.x) * sinh(z.y));
      }

      vec2 c_sinh(vec2 z)
      {
          return vec2(cos(z.y) * sinh(z.x), sin(z.y) * cosh(z.x));
      }

      vec2 c_cosh(vec2 z)
      {
          return vec2(cos(z.y) * cosh(z.x), sin(z.y) * sinh(z.x));
      }

      vec2 c_tanh(vec2 z)
      {
          return c_div(
              c_exp(z) - c_exp(-z),
              c_exp(z) + c_exp(-z)
          );
      }

      vec2 c_tan(vec2 z)
      {
          return c_mul(vec2(0, -1), c_tanh(c_mul(vec2(0, 1), z)));
      }

      vec2 c_cot(vec2 z)
      {
          return c_inv(c_tan(z));
      }

      vec2 c_sec(vec2 z)
      {
          return c_inv(c_cos(z));
      }

      vec2 c_csc(vec2 z)
      {
          return c_inv(c_sin(z));
      }

      vec2 c_cis(vec2 z)
      {
          return c_cos(z) + c_mul(i, c_sin(z));
      }

      vec2 c_asin(vec2 z)
      {
          return c_mul(
              vec2(0, -1.0),
              c_log(
                  c_mul(vec2(0, 1.0), z) + c_sqrt(vec2(1.0, 0) - c_mul(z, z))
              ));
      }

      vec2 c_acos(vec2 z)
      {
          return vec2(PI/2.0, 0) - c_asin(z);
      }

      vec2 c_atan(vec2 z)
      {
          return c_mul(
              vec2(0, 0.5),
                    c_log(vec2(1.0, 0) - c_mul(vec2(0, 1.0), z))
                  - c_log(vec2(1.0, 0) + c_mul(vec2(0, 1.0), z))
              );
      }

      vec2 c_acot(vec2 z)
      {
          return c_atan(c_inv(z));
      }


      vec2 c_asec(vec2 z)
      {
          return c_acos(c_inv(z));
      }

      vec2 c_acsc(vec2 z)
      {
          return c_asin(c_inv(z));
      }

      vec3 hsv2rgb(vec3 c)
      {
          vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
          vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
          return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
      }

      vec2 mult(vec2 left, vec2 right) {
        float r = left.x * right.x - left.y * right.y;
        float i = left.x * right.y + left.y * right.x;
        return vec2(r, i);
      }

      vec2 mult(vec2 left, vec2 right, vec2 third) {
        return mult(mult(left, right), third);
      }

      vec2 complex(float re, float im) {
        return vec2(re, im);
      }

      vec2 pow(vec2 x, int n) {
        vec2 result = vec2(x);
        for(int i = 1; i < 10000; ++i) {
          if(i >= n) {
            break;
          }
          result = c_mul(result, x);
        }

        return result;
      }

      vec2 f(vec2 z, vec2 c) {
         return %%%FORMULA_HERE%%%;
      }

      vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
          return a + b * cos( 6.28318*(c * t + d) );
      }

      uniform vec2 u_zoomCenter;
      uniform float u_zoomSize;
      uniform int u_maxIterations;
      uniform vec2 u_julia_c_value;

      void main() {
        vec2 uv = gl_FragCoord.xy / vec2(600.0, 600.0);
        vec2 c = u_zoomCenter + (uv * 4.0 - vec2(2.0)) * u_zoomSize;
        vec2 z = c;
        bool escaped = false;
        int iterations = 0;

        for (int i = 0; i < 1000000; i++) {
          if (i > u_maxIterations) break;
          iterations = i;
          z = f(z, c);

          if (%%%CONDITION_HERE%%%) {
            escaped = true;
            break;
          }
        }

        if(!error) {
          vec3 paletteColor =
            palette(
                    float(iterations) / float(u_maxIterations),
                    vec3(0.0),
                    vec3(0.59, 0.55, 0.75),
                    vec3(0.1, 0.2, 0.3),
                    vec3(0.75));

          gl_FragColor = escaped ? vec4(paletteColor, 1.0)
            : vec4(vec3(0.85, 0.99, 1.0), 1.0);
        }
        else {
          gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        }

      }