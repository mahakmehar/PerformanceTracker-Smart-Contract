// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
  PerformanceTracker

  - No imports, no constructor.
  - All user-facing recording functions take NO input parameters.
  - Each caller (msg.sender) has their own Performance record.
  - Users can:
      * recordAttempt()        -> increments attempts
      * recordSuccess()        -> increments attempts + successes
      * recordFailure()        -> increments attempts + failures
      * startSession()         -> mark session start timestamp
      * endSession()           -> compute session duration and add to totals
      * submitScore() payable  -> submit a numeric "score" encoded as msg.value (wei)
  - Read functions return the caller's aggregate data (no address inputs).
  - Events are emitted for off-chain indexing and verification.
  - This is intentionally minimal and gas-considerate.
*/

contract PerformanceTracker {
    struct Performance {
        uint256 attempts;
        uint256 successes;
        uint256 failures;
        uint256 totalSessionTime;     // cumulative seconds
        uint256 sessionCount;
        uint256 lastActive;           // timestamp of last activity
        uint256 submittedScoreSum;    // sum of msg.value used as score (wei)
        uint256 submittedScoreCount;  // number of score submissions
    }

    // mapping of user => Performance
    mapping(address => Performance) private _performances;

    // temporary per-user session start timestamps (0 means no active session)
    mapping(address => uint256) private _sessionStart;

    // Events for indexing / off-chain monitoring
    event AttemptRecorded(address indexed user, uint256 attempts);
    event SuccessRecorded(address indexed user, uint256 successes);
    event FailureRecorded(address indexed user, uint256 failures);
    event SessionStarted(address indexed user, uint256 startTimestamp);
    event SessionEnded(address indexed user, uint256 duration, uint256 totalSessionTime, uint256 sessionCount);
    event ScoreSubmitted(address indexed user, uint256 scoreWei, uint256 submittedScoreCount, uint256 submittedScoreSum);

    // ---------- Recording functions (no input params) ----------

    /// @notice Record an attempt for msg.sender
    function recordAttempt() public {
        Performance storage p = _performances[msg.sender];
        p.attempts += 1;
        p.lastActive = block.timestamp;
        emit AttemptRecorded(msg.sender, p.attempts);
    }

    /// @notice Record a success (also counts as an attempt)
    function recordSuccess() public {
        Performance storage p = _performances[msg.sender];
        p.attempts += 1;
        p.successes += 1;
        p.lastActive = block.timestamp;
        emit SuccessRecorded(msg.sender, p.successes);
    }

    /// @notice Record a failure (also counts as an attempt)
    function recordFailure() public {
        Performance storage p = _performances[msg.sender];
        p.attempts += 1;
        p.failures += 1;
        p.lastActive = block.timestamp;
        emit FailureRecorded(msg.sender, p.failures);
    }

    /// @notice Start a timed session for msg.sender. Reverts if a session is already active.
    function startSession() public {
        require(_sessionStart[msg.sender] == 0, "session already active");
        _sessionStart[msg.sender] = block.timestamp;
        _performances[msg.sender].lastActive = block.timestamp;
        emit SessionStarted(msg.sender, block.timestamp);
    }

    /// @notice End the active session for msg.sender and add its duration to totals.
    function endSession() public {
        uint256 start = _sessionStart[msg.sender];
        require(start != 0, "no active session");
        uint256 duration = block.timestamp - start;

        Performance storage p = _performances[msg.sender];
        p.totalSessionTime += duration;
        p.sessionCount += 1;
        p.lastActive = block.timestamp;

        // clear the active session
        _sessionStart[msg.sender] = 0;

        emit SessionEnded(msg.sender, duration, p.totalSessionTime, p.sessionCount);
    }

    /// @notice Submit a numeric "score" encoded as msg.value (wei). Requires msg.value > 0.
    /// Use case: send a micro-amount representing a numeric performance metric (e.g., 123 -> 123 wei).
    function submitScore() public payable {
        require(msg.value > 0, "send value as score (wei)");
        Performance storage p = _performances[msg.sender];
        p.submittedScoreSum += msg.value;
        p.submittedScoreCount += 1;
        p.lastActive = block.timestamp;
        emit ScoreSubmitted(msg.sender, msg.value, p.submittedScoreCount, p.submittedScoreSum);
    }

    // ---------- Read functions (no input params, returns caller's data) ----------

    /// @notice Returns basic counters for msg.sender
    function getMySummary()
        public
        view
        returns (
            uint256 attempts,
            uint256 successes,
            uint256 failures,
            uint256 totalSessionTime,
            uint256 sessionCount,
            uint256 lastActive,
            uint256 submittedScoreSum,
            uint256 submittedScoreCount
        )
    {
        Performance storage p = _performances[msg.sender];
        return (
            p.attempts,
            p.successes,
            p.failures,
            p.totalSessionTime,
            p.sessionCount,
            p.lastActive,
            p.submittedScoreSum,
            p.submittedScoreCount
        );
    }

    /// @notice Returns the UNIX timestamp when the caller's active session started, or 0 if none.
    function myActiveSessionStart() public view returns (uint256) {
        return _sessionStart[msg.sender];
    }

    /// @notice Returns the caller's average submitted score (wei). Returns 0 if none submitted.
    function myAverageSubmittedScore() public view returns (uint256) {
        Performance storage p = _performances[msg.sender];
        if (p.submittedScoreCount == 0) return 0;
        return p.submittedScoreSum / p.submittedScoreCount;
    }

    // ---------- Utility / convenience ----------

    /// @notice Clear session start if accidentally left (only for the caller).
    /// This prevents being stuck with an active session if desired.
    function cancelActiveSession() public {
        require(_sessionStart[msg.sender] != 0, "no active session");
        _sessionStart[msg.sender] = 0;
        _performances[msg.sender].lastActive = block.timestamp;
        // Note: session not counted when cancelled.
    }

    // ---------- Notes ----------
    // - This contract stores ETH sent via submitScore() in the contract balance.
    //   There is no withdraw function here by design (no owner/constructor). If you want
    //   an owner withdraw, we can add one — but it requires an owner to be set (no constructor => add an init function).
    //
    // - All user-facing functions intentionally have NO input parameters and rely on msg.sender and msg.value.
    // - For on-chain indexing, events are emitted for each change.
}
