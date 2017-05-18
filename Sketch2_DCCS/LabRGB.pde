
float [] rgb2Lab(float r, float g, float b) {
  float [] lab = new float[3];

  lab[0] = 0.3475 * r + 0.8231 * g + 0.5550 * b;
  lab[1] = 0.2162 * r + 0.4316 * g - 0.6411 * b;
  lab[2] = 0.1304 * r - 0.1033 * g - 0.0269 * b;
    
  return lab;
}

float [] lab2RGB(float l, float a, float b) {
  float [] rgb = new float[3];

  rgb[0] = 0.5773 * l + 0.2621 * a + 5.6947 * b;
  rgb[1] = 0.5774 * l + 0.6072 * a - 2.5444 * b;
  rgb[2] = 0.5832 * l - 1.0627 * a + 0.2073 * b;

  return rgb;
}

float [] getMeansFrom(PImage p) {
  float [] m = new float [3];

  p.loadPixels();
  for (int i = 0; i < p.pixels.length; i += 1) {
    float [] cp = rgb2Lab(red(p.pixels[i]), green(p.pixels[i]), blue(p.pixels[i]));

    for (int j = 0; j < 3; j += 1) {
      m[j] += cp[j];
    }
  }

  for (int j = 0; j < 3; j += 1) {
    m[j] /= p.pixels.length;
  }

  return m;
}



float [] getVariancesFrom(PImage p) {
  float [] m = getMeansFrom(p);
  float [] sd = new float [3];


  p.loadPixels();

  for (int i = 0; i < p.pixels.length; i += 1) {
    float [] cp = rgb2Lab(red(p.pixels[i]), green(p.pixels[i]), blue(p.pixels[i]));

    for (int j = 0; j < 3; j += 1) {
      sd[j] += ((cp[j] - m[j]) * (cp[j] - m[j]));
    }
  }

  for (int j = 0; j < 3; j += 1) {
    sd[j] = sqrt(sd[j] / p.pixels.length);
  }

  return sd;
}

int shift;

void applyScalingsFromTo(PImage r, PImage t) {
  float [] s = new float[3];
  float userScaling = 0.4;

  float [] mRef = getMeansFrom(r);
  float [] sdRef = getVariancesFrom(r);

  float [] mTarget = getMeansFrom(t);
  float [] sdTarget = getVariancesFrom(t);

  for (int j = 0; j < 3; j += 1) {
    s[j] = 1 - userScaling + userScaling * sdRef[j] / sdTarget[j];
    if(s[j] > 1)
      shift = j;
  }

  int x = 1;
  t.loadPixels();
  for (int i = 0; i < t.pixels.length; i += 1) {
    float [] cp = rgb2Lab(red(t.pixels[i]), green(t.pixels[i]), blue(t.pixels[i]));
    
    for (int j = 0; j < 3; j += 1) {
      if(j==0)
       cp[j] = (s[j] * (cp[j] - mTarget[j]) + mTarget[j])-5;
      else if(j==2)
        cp[j] = (s[j] * (cp[j] - mTarget[j]) + mTarget[j]);
      /*else if(j==1)
        cp[j] = (s[j] * (cp[j] - mTarget[j]) + mTarget[j])+1;*/
    }

    float [] rgb = lab2RGB(cp[0], cp[1], cp[2]);
    t.pixels[i] = color(rgb[0], rgb[1], rgb[2]);
  }
  
  t.updatePixels();
}