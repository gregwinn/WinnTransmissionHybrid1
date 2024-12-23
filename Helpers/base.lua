-- PID Controller
-- @param setPoint number: The target value we want to achieve (e.g., target RPS)
-- @param processVariable number: The current value of the system (e.g., current RPS)
-- @param dt number: Time elapsed since the last update (in seconds)
-- @param pidTable table: Table containing PID parameters and state (Kp, Ki, Kd, integral, prevError)
-- @return number: The output value to adjust the system (e.g., throttle adjustment)
function pidController(setPoint, processVariable, dt, pidTable)
    -- Extract PID parameters
    local Kp = pidTable.Kp or 0
    local Ki = pidTable.Ki or 0
    local Kd = pidTable.Kd or 0

    -- Initialize state if not already done
    pidTable.integral = pidTable.integral or 0
    pidTable.prevError = pidTable.prevError or 0

    -- Calculate error
    local error = setPoint - processVariable

    -- Proportional term
    local proportional = Kp * error

    -- Integral term
    pidTable.integral = pidTable.integral + error * dt
    local integral = Ki * pidTable.integral

    -- Derivative term
    local derivative = 0
    if dt > 0 then
        derivative = Kd * (error - pidTable.prevError) / dt
    end

    -- Update previous error
    pidTable.prevError = error

    -- Combine terms to produce output
    return proportional + integral + derivative
end
-- Min-Max function
---@param value number
---@param min_value number
---@param max_value number
---@return number
function clamp(value, min_value, max_value)
    if value < min_value then
        return min_value
    elseif value > max_value then
        return max_value
    else
        return value
    end
end