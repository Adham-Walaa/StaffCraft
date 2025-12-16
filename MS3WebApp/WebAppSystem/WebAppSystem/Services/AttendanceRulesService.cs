using System;
using System.Linq;
using WebAppSystem.Models;

namespace WebAppSystem.Services
{
    public class AttendanceRulesService
    {
        private readonly int _gracePeriodMinutes = 15; // Default grace period
        private readonly int _shortTimePenaltyMinutes = 30; // Deduction for short time

        public AttendanceRulesService()
        {
        }

        // Check if employee is late considering grace period
        public bool IsLate(TimeOnly? entryTime, TimeOnly? shiftStartTime)
        {
            if (!entryTime.HasValue || !shiftStartTime.HasValue)
                return false;

            var entryMinutes = entryTime.Value.Hour * 60 + entryTime.Value.Minute;
            var shiftMinutes = shiftStartTime.Value.Hour * 60 + shiftStartTime.Value.Minute;
            var lateMinutes = entryMinutes - shiftMinutes;

            return lateMinutes > _gracePeriodMinutes;
        }

        // Calculate late minutes after grace period
        public int CalculateLateMinutes(TimeOnly? entryTime, TimeOnly? shiftStartTime)
        {
            if (!entryTime.HasValue || !shiftStartTime.HasValue)
                return 0;

            var entryMinutes = entryTime.Value.Hour * 60 + entryTime.Value.Minute;
            var shiftMinutes = shiftStartTime.Value.Hour * 60 + shiftStartTime.Value.Minute;
            var lateMinutes = entryMinutes - shiftMinutes;

            return Math.Max(0, lateMinutes - _gracePeriodMinutes);
        }

        // Apply short-time penalty
        public int ApplyShortTimePenalty(int? duration)
        {
            if (!duration.HasValue)
                return 0;

            // If duration is significantly short, apply penalty
            if (duration.Value < 480) // Less than 8 hours
            {
                return _shortTimePenaltyMinutes;
            }

            return 0;
        }

        // Check if early departure
        public bool IsEarlyDeparture(TimeOnly? exitTime, TimeOnly? shiftEndTime)
        {
            if (!exitTime.HasValue || !shiftEndTime.HasValue)
                return false;

            var exitMinutes = exitTime.Value.Hour * 60 + exitTime.Value.Minute;
            var shiftEndMinutes = shiftEndTime.Value.Hour * 60 + shiftEndTime.Value.Minute;

            return exitMinutes < (shiftEndMinutes - _gracePeriodMinutes);
        }

        // Calculate early departure minutes
        public int CalculateEarlyDepartureMinutes(TimeOnly? exitTime, TimeOnly? shiftEndTime)
        {
            if (!exitTime.HasValue || !shiftEndTime.HasValue)
                return 0;

            var exitMinutes = exitTime.Value.Hour * 60 + exitTime.Value.Minute;
            var shiftEndMinutes = shiftEndTime.Value.Hour * 60 + shiftEndTime.Value.Minute;
            var earlyMinutes = shiftEndMinutes - exitMinutes;

            return Math.Max(0, earlyMinutes - _gracePeriodMinutes);
        }

        // Apply time rules to attendance
        public void ApplyTimeRules(Attendance attendance, ShiftSchedule? shift)
        {
            if (shift == null)
                return;

            // Check lateness
            if (IsLate(attendance.EntryTime, shift.StartTime))
            {
                var lateMinutes = CalculateLateMinutes(attendance.EntryTime, shift.StartTime);
                // Could store this in a separate penalties table or use exceptions
            }

            // Check early departure
            if (IsEarlyDeparture(attendance.ExitTime, shift.EndTime))
            {
                var earlyMinutes = CalculateEarlyDepartureMinutes(attendance.ExitTime, shift.EndTime);
                // Could store this in a separate penalties table or use exceptions
            }

            // Apply short-time penalty if applicable
            var penalty = ApplyShortTimePenalty(attendance.Duration);
            if (penalty > 0)
            {
                // Deduct penalty from duration
                attendance.Duration = Math.Max(0, (attendance.Duration ?? 0) - penalty);
            }
        }
    }
}
