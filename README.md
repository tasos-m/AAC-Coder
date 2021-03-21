# AAC-Coder
The assignment is a part of the course "Multimedia Systems" in the Department of Electrical & Computer Engineering of the Aristotle University of Thessaloniki. The goal is to build our own implementation of AAC Coder.  


## First Level

* SIN window 

| Left Channel SNR | 307.8288 |
| --- | --- |
| **Right Channel SNR** | **307.8950** |
| **Total SNR** | **307.8619** |

* KBD window 

| Left Channel SNR | 308.6251 |
| --- | --- |
| **Right Channel SNR** | **308.6251** |
| **Total SNR** | **308.6432** |


## Second Level 

* SIN window 

| Left Channel SNR | 307.8248 |
| --- | --- |
| **Right Channel SNR** | **307.8630** |
| **Total SNR** | **307.8439** |

* KBD window 

| Left Channel SNR | 308.5930 |
| --- | --- |
| **Right Channel SNR** | **308.6149** |
| **Total SNR** | **308.6039** |

## Third Level

* SIN window & without normalization of the decoded sequence

| Left Channel SNR | 3.6794 |
| --- | --- |
| **Right Channel SNR** | **3.1785** |
| **Total SNR** | **3.4290** |

| Bitrate  | 486740 bps |
| --- | --- |
| **Compression** | **0.3149** |
| **Encoding Elapsed Time** | **43.13 sec** |
| **Decoding Elapsed Time** | **2.74 sec** |

* SIN window & with normalization of the decoded sequence

| Left Channel SNR | 10.3284 |
| --- | --- |
| **Right Channel SNR** | **8.6215** |
| **Total SNR** | **9.4749** |

| Bitrate  | 483710 bps |
| --- | --- |
| **Compression** | **0.3149** |
| **Encoding Elapsed Time** | **42.85 sec** |
| **Decoding Elapsed Time** | **2.75 sec** |

* KBD window & without normalization of the decoded sequence

| Left Channel SNR | 3.6090 |
| --- | --- |
| **Right Channel SNR** | **3.1402** |
| **Total SNR** | **3.3746** |

| Bitrate  | 483720 bps |
| --- | --- |
| **Compression** | **0.3149** |
| **Encoding Elapsed Time** | **54.35 sec** |
| **Decoding Elapsed Time** | **3.06 sec** |


* KBD window & with normalization of the decoded sequence

| Left Channel SNR | 10.0685 |
| --- | --- |
| **Right Channel SNR** | **9.8234** |
| **Total SNR** | **9.9460** |

| Bitrate  | 483720 bps |
| --- | --- |
| **Compression** | **0.3149** |
| **Encoding Elapsed Time** | **52.94 sec** |
| **Decoding Elapsed Time** | **4.27 sec** |

## Running Instructions

The input audio file used for the experiments [Licor De Calandraca](https://github.com/tasos-m/AAC-Coder/blob/main/LicorDeCalandraca.wav). 
In order to run the experiment to your computer, you' ll have to follow these steps:
* Have installed MATLAB
* For each level, copy the input file inside the level directory.
* After this, in order to run each level separately, you should write in the MATLAB command line, while you are inside the corresponding directory:
  - Level 1; SNR = demoAAC1('LicorDeCalandraca.wav','out.wav');
  - Level 2; SNR = demoAAC1('LicorDeCalandraca.wav','out.wav');
  - Level 3; [SNR,bitrate,compression] = demoAAC3('LicorDeCalandraca.wav','out.wav','out.mat');
* If you want to change the window from SIN to KBD, you should change the **winType** to "KBD" inside the AACoder{i}.m function where i = 1, 2, 3 for each level.

## Report

You can read the report about this project in Greek is [here](https://github.com/tasos-m/AAC-Coder/blob/main/report.pdf) 
