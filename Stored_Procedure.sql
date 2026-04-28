
--C1) Patient Age Calculator 

CREATE FUNCTION fn_GetPatientAge_2252 (@PatientID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Age INT;
    
    SELECT @Age = DATEDIFF(YEAR, DateOfBirth, GETDATE()) - 
                  CASE 
                    WHEN (MONTH(DateOfBirth) > MONTH(GETDATE())) OR 
                         (MONTH(DateOfBirth) = MONTH(GETDATE()) AND DAY(DateOfBirth) > DAY(GETDATE())) 
                    THEN 1 ELSE 0 
                  END
    FROM VED_Patients_2252
    WHERE PatientID = @PatientID;

    RETURN @Age; -- Returns NULL automatically if PatientID doesn't exist
END;
GO
--Test:  Demonstration Query
SELECT PatientID, FirstName + ' ' + LastName AS PatientName, 
       dbo.fn_GetPatientAge_2252(PatientID) AS CalculatedAge
FROM VED_Patients_2252;

--C2) Net Bill Calculator

CREATE FUNCTION fn_CalculateNetBill_2252 (
    @Consultation DECIMAL(18,2),
    @Medicine DECIMAL(18,2),
    @Lab DECIMAL(18,2),
    @InsurancePercent DECIMAL(5,2)
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Subtotal DECIMAL(18,2) = @Consultation + @Medicine + @Lab;
    DECLARE @GST DECIMAL(18,2) = @Subtotal * 0.18;
    DECLARE @InsuranceDiscount DECIMAL(18,2) = @Subtotal * (@InsurancePercent / 100.0);
    
    RETURN (@Subtotal + @GST) - @InsuranceDiscount;
END;
GO

--Test: Demonstration Query:
SELECT 
    BillID, 
    FinalAmount AS StoredTotal,
    dbo.fn_CalculateNetBill_2252(ConsultationCharge, MedicineCost, LabCost, 0) AS CalculatedNoInsurance,
    -- Using 10% as a test case for insurance
    dbo.fn_CalculateNetBill_2252(ConsultationCharge, MedicineCost, LabCost, 10.00) AS CalculatedWith10Percent
FROM VED_Billing_2252;


--D1) Top 3 Revenue-Generating Doctors per Department (Advanced Query)

WITH DoctorRevenue AS (
    -- Step 1: Aggregate revenue and apply the window function
    SELECT 
        dep.DepartmentName,
        d.FirstName + ' ' + d.LastName AS DoctorName,
        SUM(b.FinalAmount) AS TotalRevenue,
        -- Window Function: Ranks doctors 1, 2, 3 within each department
        DENSE_RANK() OVER (
            PARTITION BY dep.DepartmentName 
            ORDER BY SUM(b.FinalAmount) DESC
        ) AS DeptRank
    FROM VED_Doctors_2252 d
    JOIN VED_Departments_2252 dep ON d.DepartmentID = dep.DepartmentID
    JOIN VED_Appointments_2252 a ON d.DoctorID = a.DoctorID
    JOIN VED_Billing_2252 b ON a.AppointmentID = b.AppointmentID
    WHERE a.Status = 'Completed'
    GROUP BY dep.DepartmentName, d.FirstName, d.LastName
)
-- Step 2: Filter the results from the CTE
SELECT 
    DepartmentName, 
    DoctorName, 
    TotalRevenue, 
    DeptRank
FROM DoctorRevenue
WHERE DeptRank <= 3
ORDER BY DepartmentName, DeptRank;


--D2) Running Monthly Revenue Total (Advanced Query)

WITH MonthlyTotals AS (
    -- Step 1: Group data by month and year
    SELECT 
        YEAR(p.PaymentDate) AS PayYear,
        MONTH(p.PaymentDate) AS PayMonth,
        FORMAT(p.PaymentDate, 'MMM yyyy') AS [MonthYear],
        SUM(p.AmountPaid) AS MonthlyRevenue,
        MIN(p.PaymentDate) AS FirstDateOfMonth -- Used for chronological sorting
    FROM VED_Payment_2252 p
    GROUP BY YEAR(p.PaymentDate), MONTH(p.PaymentDate), FORMAT(p.PaymentDate, 'MMM yyyy')
)
-- Step 2: Calculate the running total from the aggregated CTE
SELECT 
    [MonthYear],
    MonthlyRevenue,
    SUM(MonthlyRevenue) OVER (ORDER BY PayYear, PayMonth) AS CumulativeTotal
FROM MonthlyTotals
ORDER BY PayYear, PayMonth;


