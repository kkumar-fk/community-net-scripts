# Network and System Metrics Scripts

This repository is a collection of Bash scripts focused on Linux network performance testing, system metrics, and tuning. These scripts have been useful in real-world environments for benchmarking and evaluating NIC cards, investigating, analyzing, and testing networking behavior, IRQ/XPS/aRFS settings, softirqs, and system utilization.

Feel free to use, modify, or contribute — no obligations. I’ll keep improving these as time permits.

## 📂 List of Scripts

|------------------------|----------------------------------------------------|
|  Script Name           |         Purpose (Brief Description)                |
|------------------------|----------------------------------------------------|
| `arfs.sh`              | Get, Check or Set ARFS.                            |
| `compare.sh`           | Compare results from two test runs                 |
| `drops.sh`             | Collect packet drop statistics from interface.     |
| `get_irq.sh`           | Retrieve IRQ info (affinity, CPU usage, etc).      |
| `get_xps.sh`           | Show current XPS settings                          |
| `ipi.sh`               | Calculate inter-processor interrupts.              |
| `netperf_test.sh`      | Run `netperf` tests with preset parameters.        |
| `parse_all_files.sh    | Batch process metrics from multiple result files.  | 
| `pkts.sh`              | Monitor packet rate per queue.                     |
| `retrans.sh`           | Calculate TCP retransmissions.                     |
| `run_all_tests.sh`     | Master test suite to run some predefined tests     |
| `save_arfs.sh`         | Save sysctls (can ignore unless kernel changes     |
| `set_irq.sh`           | Set IRQ CPU affinities.                            |
| `set_irq_xps_arfs.sh`  | Configure IRQs, XPS, and ARFS in one go.           |
| `set_xps.sh`           | Configure Transmit Packet Steering (XPS).          |
| `softirq.sh`           | Calculate softirq activity.                        |
| `sysctl.sh`            | Print and/or clear sysctl parameters.              |
| `system_util.sh`       | Collect CPU stats.                                 |
| `test_with_metrics.sh` | Collect metrics & start netperf_test.sh            |
| `total_pkts.sh`        | Count total tx/rx packets over interface.          |
|------------------------|----------------------------------------------------|

## 🚧 TODOs

- Currently, scripts rely on fixed argument ordering.
- `getopts` is not implemented yet for flexible CLI options.

---

## 🚀 Notes on Script Customization

While most of the 21 scripts included should work out of the box, a few may require minor modifications depending on your specific test setup. These scripts were tested on a 144-core system with processes pinned to CPUs 0–71. This setup allowed for measurement of packet processing on expected cores (0–71) versus unexpected cores (72–143).

The following scripts may require changes:

1. compare.sh – Assumes tests are run on CPUs 0–71. If your test setup differs, update the CPU ranges (0–71 and 72–143) accordingly. If you're not interested in distinguishing unexpected cores, you may simplify by analyzing all queues without filtering.

2. drops.sh and pkts.sh – These rely on standardized metrics from modern ethtool output and typically should not require any changes.

3. netperf_test.sh – If you do not want to pin test processes to a specific set of CPUs, uncomment the lcpus=72 line.

4. parse_all_files.sh – Contains lines referencing CPU ranges (0–71 / 72–143). If you're running tests across all cores, you can remove or modify those filters.

5. run_all_tests.sh – This is the main driver script. Set the appropriate values for CONN, RPS, and other parameters as required for your tests.

---

## 🚀 How to Run the Test Suite

1. The main entry point is `run_all_tests.sh`. You can modify this script as needed.
2. Run it as follows:
   ./run_all_tests.sh <IP> {Time} {Device} &

    Examples:
	nohup ./run_all_tests.sh 10.65.36.80 &
	nohup ./run_all_tests.sh 10.65.36.80 180 ens3f0 &
3. Output files will be generated under the Results/ directory.

---

## 🚀 How to analyze the test results

1. After a test run, move the results to a new directory:
	- mkdir Results/org
	- mv Results/*.out Results/org
2. If a second run was done, store those separately:
	- mkdir Results/new
	- mv Results/*.out Results/new
3. Parse the first run:
	(cd Results/org; ./parse_all_files.sh > /tmp/org)
4. Optionally, parse and compare a second run:
	(cd Results/new; ./parse_all_files.sh > /tmp/new)
	./compare.sh /tmp/org /tmp/new

---

## 🚧 Sample Parsed Output

| Metric                  | Org        | New        |
|-------------------------|------------|------------|
| Pkts on Queues 0-71     | 15,738,551 | 16,324,101 |
| Pkts on Queues 72-143   | 48,295     | 5,289      |
| CPU Utilization         | 12.67      | 10.52      |
| Number IPI's/sec        | 12,522     | 2,256      |
| Packets sent            | 68,529,174 | 68,510,125 |
| Packets recvd           | 17,813,593 | 18,592,262 |
| Packets dropped         | 0          | 0          |
| Segments retransmitted  | 376,421    | 355,243    |
| SoftIRQ events          | 121,976,064| 12,243,852 |
| aRFS Skip               | 15,890     | 1          |
| aRFS Update             | 268,956    | 9,833      |
| Wrong aRFS avoided      | 0          | 3,642      |
| Total aRFS events       | 284,846    | 13,476     |


## 📌 Notes
- Some scripts require `sudo` privileges.
- All scripts are written in Bash and tested on Debian 12.
- You’re free to use these as-is or tweak them for your needs.

## 📄 License

This project is licensed under the [MIT License](./LICENSE).

---
