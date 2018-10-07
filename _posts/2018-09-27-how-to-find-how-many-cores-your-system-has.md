---
id: 5320
title: How to find how many cores your system has
date: 2018-09-27T02:04:54+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=5320
permalink: /2018/09/how-to-find-how-many-cores-your-system-has/
categories:
  - Linux
tags:
  - linux
---
To get information about the CPU architecture of the system we can use **lscpu**, which is a frontend for **/proc/cpuinfo**. A run of **lscpu** on my system gives this output:

```
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                4
On-line CPU(s) list:   0-3
Thread(s) per core:    2
Core(s) per socket:    2
Socket(s):             1
NUMA node(s):          1
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 142
Model name:            Intel(R) Core(TM) i7-7600U CPU @ 2.80GHz
Stepping:              9
CPU MHz:               900.020
CPU max MHz:           3900.0000
CPU min MHz:           400.0000
BogoMIPS:              5808.00
Virtualization:        VT-x
L1d cache:             32K
L1i cache:             32K
L2 cache:              256K
L3 cache:              4096K
NUMA node0 CPU(s):     0-3
Flags:                 fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb invpcid_single pti retpoline intel_pt rsb_ctxsw spec_ctrl ssbd tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clflushopt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp
```

The **Sockets** field means the actual CPU chips in the motherboard. **Cores per socket** means how many physical cores the chip has. **Threads per core** tells us if the cores support multi-threading.

The total number of parallel threads this system can execute is 4 (Sockets \* Cores \* Threads). This is the same as the value of the **CPU(s)** field.

The same information can be obtained using **nproc &#8211;all**, which prints the number of processing units in the system.
