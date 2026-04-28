CREATE TABLE VED_Departments_2252 (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(100) NOT NULL,
    HeadDoctorID INT NULL -- Will be updated after Doctors are created
);

CREATE TABLE VED_Doctors_2252 (
    DoctorID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    DepartmentID INT NOT NULL FOREIGN KEY REFERENCES VED_Departments_2252(DepartmentID),
    Specialization NVARCHAR(100),
    ConsultationFee DECIMAL(18,2) NOT NULL CHECK (ConsultationFee >= 0),
    IsActive BIT DEFAULT 1,
);

CREATE TABLE VED_Schedules_2252 (
    ScheduleID INT PRIMARY KEY IDENTITY(1,1),
    DoctorID INT NOT NULL FOREIGN KEY REFERENCES VED_Doctors_2252(DoctorID),
    DayOfWeek NVARCHAR(15) CHECK (DayOfWeek IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL
);

CREATE TABLE VED_Patients_2252 (
    PatientID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Phone NVARCHAR(20),
    Address NVARCHAR(MAX),
    InsurancePolicyNo NVARCHAR(50),
    TotalUnpaidBalance DECIMAL(18,2) DEFAULT 0.00 CHECK (TotalUnpaidBalance <= 200000.00) -- Rule 10
);

CREATE TABLE VED_Insurance_2252 (
    InsuranceID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT NOT NULL UNIQUE FOREIGN KEY REFERENCES VED_Patients_2252(PatientID),
    ProviderName NVARCHAR(100),
    CoveragePercentage DECIMAL(5,2) DEFAULT 0 CHECK (CoveragePercentage BETWEEN 0 AND 100),
    YearlyMaximum DECIMAL(18,2) NOT NULL,
    UsedAmountYearly DECIMAL(18,2) DEFAULT 0
);

CREATE TABLE VED_Appointments_2252 (
    AppointmentID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT NOT NULL FOREIGN KEY REFERENCES VED_Patients_2252(PatientID),
    DoctorID INT NOT NULL FOREIGN KEY REFERENCES VED_Doctors_2252(DoctorID),
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    Status NVARCHAR(20) DEFAULT 'Scheduled' CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled'))
);

CREATE TABLE VED_MedicalRecords_2252 (
    RecordID INT PRIMARY KEY IDENTITY(1,1),
    AppointmentID INT NOT NULL UNIQUE FOREIGN KEY REFERENCES VED_Appointments_2252(AppointmentID),
    Diagnosis NVARCHAR(MAX),
    TreatmentPlan NVARCHAR(MAX),
    RequiresFollowUp BIT DEFAULT 0
);

CREATE TABLE VED_Medicines_2252 (
    MedicineID INT PRIMARY KEY IDENTITY(1,1),
    MedicineName NVARCHAR(100) NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL
);

CREATE TABLE VED_Prescriptions_2252 (
    PrescriptionID INT PRIMARY KEY IDENTITY(1,1),
    RecordID INT NOT NULL FOREIGN KEY REFERENCES VED_MedicalRecords_2252(RecordID),
    MedicineID INT NOT NULL FOREIGN KEY REFERENCES VED_Medicines_2252(MedicineID),
    Quantity INT NOT NULL,
    Dosage NVARCHAR(100),
    DurationDays INT
);

CREATE TABLE VED_LabTests_2252 (
    TestID INT PRIMARY KEY IDENTITY(1,1),
    TestName NVARCHAR(100) NOT NULL,
    BaseCost DECIMAL(18,2) NOT NULL
);

CREATE TABLE  VED_LabOrders_2252 (
    LabOrderID INT PRIMARY KEY IDENTITY(1,1),
    AppointmentID INT NOT NULL FOREIGN KEY REFERENCES VED_Appointments_2252(AppointmentID),
    TestID INT NOT NULL FOREIGN KEY REFERENCES VED_LabTests_2252(TestID),
    Result NVARCHAR(MAX),
    IsAbnormal BIT DEFAULT 0
);
CREATE TABLE VED_Billing_2252 (
    BillID INT PRIMARY KEY IDENTITY(1,1),
    AppointmentID INT NOT NULL UNIQUE FOREIGN KEY REFERENCES VED_Appointments_2252(AppointmentID),
    ConsultationCharge DECIMAL(18,2) NOT NULL,
    MedicineCost DECIMAL(18,2) DEFAULT 0,
    LabCost DECIMAL(18,2) DEFAULT 0,
    InsuranceDiscount DECIMAL(18,2) DEFAULT 0,
    GST DECIMAL(18,2) NOT NULL,
    FinalAmount DECIMAL(18,2) NOT NULL,
    PaymentStatus NVARCHAR(30) DEFAULT 'Unpaid' CHECK (PaymentStatus IN ('Paid', 'Unpaid'))
);

CREATE TABLE VED_Payment_2252 (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    BillID INT NOT NULL UNIQUE FOREIGN KEY REFERENCES VED_Billing_2252(BillID),
    AmountPaid DECIMAL(18,2) NOT NULL CHECK (AmountPaid >= 0),
    PaymentMethod NVARCHAR(100) NOT NULL CHECK (PaymentMethod IN ('Cash', 'Card', 'Insurance', 'Online')),
    PaymentDate DATETIME DEFAULT GETDATE() -- Changed to DATETIME for precision
);

INSERT INTO VED_Departments_2252 (DepartmentName) VALUES 
('Cardiology'), ('Orthopaedics'), ('Pathology'), ('Pediatrics'), ('Neurology');

-- Doctors
INSERT INTO VED_Doctors_2252 (FirstName, LastName, DepartmentID, Specialization, ConsultationFee) VALUES 
('John', 'Smith', 1, 'Cardiologist', 800.00),
('Sarah', 'Johnson', 1, 'Heart Surgeon', 1200.00),
('Robert', 'Brown', 2, 'Bone Specialist', 600.00),
('Emily', 'Davis', 2, 'Sports Medicine', 700.00),
('Michael', 'Wilson', 3, 'Pathologist', 500.00),
('Jessica', 'Taylor', 4, 'Pediatrician', 550.00),
('David', 'Miller', 5, 'Neurologist', 950.00);

-- Update Head Doctors
UPDATE VED_Departments_2252 SET HeadDoctorID = 1 WHERE DepartmentID = 1;
UPDATE VED_Departments_2252 SET HeadDoctorID = 3 WHERE DepartmentID = 2;
UPDATE VED_Departments_2252 SET HeadDoctorID = 5 WHERE DepartmentID = 3;

-- Patients
INSERT INTO VED_Patients_2252 (FirstName, LastName, DateOfBirth, Phone, Address, InsurancePolicyNo) VALUES 
('Alice', 'Green', '1985-05-12', '9876543210', '123 Pine St', 'POL101'),
('Bob', 'White', '1990-11-22', '9876543211', '456 Oak St', 'POL102'),
('Charlie', 'Black', '1975-02-28', '9876543212', '789 Maple St', NULL),
('Diana', 'Prince', '1995-07-15', '9876543213', '101 Amazon Way', 'POL103'),
('Edward', 'Norton', '1982-03-30', '9876543214', '202 Fight Club Rd', NULL);

-- Insurance
INSERT INTO VED_Insurance_2252 (PatientID, ProviderName, CoveragePercentage, YearlyMaximum) VALUES 
(1, 'MediCare Plus', 80.00, 50000.00),
(2, 'HealthSecure', 50.00, 20000.00),
(4, 'LifeFirst', 100.00, 100000.00);

-- Appointments
INSERT INTO VED_Appointments_2252 (PatientID, DoctorID, AppointmentDate, AppointmentTime, Status) VALUES 
(1, 1, '2026-03-10', '09:30', 'Completed'),
(2, 3, '2026-03-11', '10:00', 'Completed'),
(3, 5, '2026-03-12', '11:00', 'Completed'),
(4, 2, '2026-03-12', '10:30', 'Scheduled'),
(5, 7, '2026-03-13', '09:00', 'Cancelled');

-- Medical Records
INSERT INTO VED_MedicalRecords_2252 (AppointmentID, Diagnosis, TreatmentPlan) VALUES 
(1, 'Hypertension', 'Low salt diet and medication'),
(2, 'Fractured Ankle', 'Plaster cast for 4 weeks'),
(3, 'Routine Blood Work', 'Check cholesterol levels');

-- Catalog (Meds & Tests)
INSERT INTO VED_Medicines_2252 (MedicineName, UnitPrice) VALUES 
('Amlodipine', 10.00), ('Amoxicillin', 15.00), ('Ibuprofen', 5.00), ('Lipitor', 25.00);

INSERT INTO VED_LabTests_2252 (TestName, BaseCost) VALUES 
('Blood Sugar', 200.00), ('X-Ray Chest', 800.00), ('ECG', 1200.00), ('Lipid Profile', 1500.00);

-- Prescriptions & Lab Orders
INSERT INTO VED_Prescriptions_2252 (RecordID, MedicineID, Quantity, Dosage, DurationDays) VALUES 
(1, 1, 30, '5mg once daily', 30),
(2, 3, 20, '400mg as needed', 10);

INSERT INTO VED_LabOrders_2252 (AppointmentID, TestID, Result, IsAbnormal) VALUES 
(1, 3, 'Normal Rhythm', 0),
(2, 2, 'Hairline Fracture Visible', 1),
(3, 4, 'High Cholesterol', 1);

-- Billing & Payments
INSERT INTO VED_Billing_2252 (AppointmentID, ConsultationCharge, MedicineCost, LabCost, InsuranceDiscount, GST, FinalAmount, PaymentStatus) VALUES 
(1, 800.00, 300.00, 1200.00, 1200.00, 120.00, 1220.00, 'Paid'),
(2, 600.00, 100.00, 800.00, 450.00, 85.00, 1135.00, 'Unpaid');

INSERT INTO VED_Payment_2252 (BillID, AmountPaid, PaymentMethod) VALUES 
(1, 1220.00, 'Card');

-- Adding 10 more samples for Doctors 1 and 2 to cross the 'Minimum 5' threshold
INSERT INTO VED_Appointments_2252 (PatientID, DoctorID, AppointmentDate, AppointmentTime, Status) VALUES 
(1, 1, '2026-03-15', '09:00', 'Completed'),
(2, 1, '2026-03-16', '10:00', 'Completed'),
(3, 1, '2026-03-17', '11:00', 'Completed'),
(4, 1, '2026-03-18', '09:30', 'Cancelled'),
(5, 1, '2026-03-19', '10:30', 'Completed'),
(1, 2, '2026-03-15', '14:00', 'Completed'),
(2, 2, '2026-03-16', '15:00', 'Completed'),
(3, 2, '2026-03-17', '16:00', 'Completed'),
(4, 2, '2026-03-18', '14:30', 'Completed'),
(5, 2, '2026-03-19', '15:30', 'Completed');

-- Adding some Billing records for these new appointments 
-- (Revenue won't show in the report without these)
INSERT INTO VED_Billing_2252 (AppointmentID, ConsultationCharge, MedicineCost, LabCost, InsuranceDiscount, GST, FinalAmount, PaymentStatus) VALUES 
(6, 800.00, 0, 0, 0, 80.00, 880.00, 'Paid'),
(7, 800.00, 50.00, 0, 0, 85.00, 935.00, 'Paid'),
(8, 800.00, 0, 200.00, 0, 100.00, 1100.00, 'Unpaid'),
(10, 800.00, 100.00, 0, 0, 90.00, 990.00, 'Paid'),
(11, 1200.00, 0, 0, 0, 120.00, 1320.00, 'Paid'),
(12, 1200.00, 0, 0, 0, 120.00, 1320.00, 'Paid'),
(13, 1200.00, 0, 0, 0, 120.00, 1320.00, 'Paid'),
(14, 1200.00, 0, 0, 0, 120.00, 1320.00, 'Paid'),
(15, 1200.00, 0, 0, 0, 120.00, 1320.00, 'Paid');

-- Simulate a huge payment to hit the target for testing
INSERT INTO VED_Billing_2252 (AppointmentID, ConsultationCharge, MedicineCost, LabCost, InsuranceDiscount, GST, FinalAmount, PaymentStatus)
VALUES (4, 450000.00, 20000.00, 30000.00, 0, 50000.00, 550000.00, 'Paid');

INSERT INTO VED_Payment_2252 (BillID, AmountPaid, PaymentMethod, PaymentDate)
VALUES (SCOPE_IDENTITY(), 550000.00, 'Online', '2026-03-15');


PRINT 'Additional data added. You can now run the Performance Report.';



BEGIN TRANSACTION;

ROLLBACK;

-- STORED PROCEDURE (A1)
CREATE PROCEDURE sp_MonthlyDepartmentReport_2252
    @ReportMonth INT,
    @ReportYear INT
AS
BEGIN
    -- Basic parameter validation
    IF @ReportMonth < 1 OR @ReportMonth > 12
    BEGIN
        THROW 50001, 'Invalid month. Please provide a value between 1 and 12.', 1;
    END

    BEGIN TRY
        SELECT 
            d.DepartmentName,
            COUNT(a.AppointmentID) AS TotalAppointments,
            COUNT(DISTINCT a.PatientID) AS UniquePatientsSeen,
            ISNULL(SUM(b.ConsultationCharge), 0) AS TotalConsultationRevenue
        FROM VED_Departments_2252 d
        LEFT JOIN VED_Doctors_2252 doc ON d.DepartmentID = doc.DepartmentID
        LEFT JOIN VED_Appointments_2252 a ON doc.DoctorID = a.DoctorID 
            AND MONTH(a.AppointmentDate) = @ReportMonth 
            AND YEAR(a.AppointmentDate) = @ReportYear
        LEFT JOIN VED_Billing_2252 b ON a.AppointmentID = b.AppointmentID
        GROUP BY d.DepartmentName
        ORDER BY TotalConsultationRevenue DESC;
    END TRY
    BEGIN CATCH
        THROW; -- Re-throw the error to the calling application
    END CATCH
END;

EXEC sp_MonthlyDepartmentReport_2252 @ReportMonth = 3, @ReportYear = 2026;


--A2) Patients Billing Summary
CREATE PROCEDURE sp_PatientBillingStatement_2252 
    @PatientID INT
AS
BEGIN
    
    IF NOT EXISTS(SELECT 1 FROM VED_Patients_2252 WHERE PatientID = @PatientID)
    BEGIN
        THROW 50002, 'Error: The provided Patient ID does not exist in our records.', 1;
    END

    BEGIN TRY
        SELECT ISNULL(CAST(a.AppointmentDate as VARCHAR), 'Grand Total') AS [DATE],
        ISNULL(d.FirstName + ' ' + d.LastName, '---') AS DoctorName,
        SUM(ConsultationCharge) AS ConsultCharge,
        SUM(MedicineCost) AS TotalMedCost,
        SUM(LabCost) AS TotalLabCost,
        SUM(InsuranceDiscount) AS InsDiscont,
        SUM(GST) AS GSTCharged,
        SUM(FinalAmount) AS FinalPayble
        FROM VED_Patients_2252 as p
        JOIN VED_Appointments_2252 as a ON p.PatientID = a.PatientID
        JOIN VED_Doctors_2252 as d ON a.DoctorID = d.DoctorID
        JOIN VED_Billing_2252 b ON a.AppointmentID = b.AppointmentID
        WHERE p.PatientID = @PatientID
          AND a.Status = 'Completed'
        GROUP BY ROLLUP((a.AppointmentDate, d.FirstName, d.Lastname, a.AppointmentID))
        HAVING a.AppointmentID IS NOT NULL OR GROUPING(a.AppointmentID) = 1
        ORDER BY GROUPING(a.AppointmentID), a.AppointmentDate;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;

EXEC sp_PatientBillingStatement_2252 @PatientID = 1;

--A3) Doctor Performance Report
/* A3: Doctor Performance Report
   Calculates revenue and completion rates for doctors with 5+ appointments.
*/

CREATE PROCEDURE sp_DoctorPerformanceReport_2252
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    -- 1. Date Validation
    IF @StartDate > @EndDate
    BEGIN
        THROW 50003, 'Invalid Range: Start Date cannot be after End Date.', 1;
    END

    BEGIN TRY
        SELECT 
            d.FirstName + ' ' + d.LastName AS DoctorName,
            dep.DepartmentName,
            COUNT(a.AppointmentID) AS TotalScheduled,
            -- Conditional Counting
            SUM(CASE WHEN a.Status = 'Completed' THEN 1 ELSE 0 END) AS TotalCompleted,
            -- Revenue from Billing
            ISNULL(SUM(b.FinalAmount), 0) AS RevenueGenerated,
            -- Percentage Calculation
            CAST(
                (SUM(CASE WHEN a.Status = 'Completed' THEN 1.0 ELSE 0.0 END) / 
                 NULLIF(COUNT(a.AppointmentID), 0)) * 100 
            AS DECIMAL(5,2)) AS CompletionRate
        FROM VED_Doctors_2252 d
        JOIN VED_Departments_2252 dep ON d.DepartmentID = dep.DepartmentID
        JOIN VED_Appointments_2252 a ON d.DoctorID = a.DoctorID
        LEFT JOIN VED_Billing_2252 b ON a.AppointmentID = b.AppointmentID
        WHERE a.AppointmentDate BETWEEN @StartDate AND @EndDate
        GROUP BY d.FirstName, d.LastName, dep.DepartmentName
        -- Business Rule: Minimum 5 appointments
        HAVING COUNT(a.AppointmentID) >= 5
        ORDER BY RevenueGenerated DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
BEGIN TRANSACTION
ROLLBACK
EXEC sp_DoctorPerformanceReport_2252 @StartDate = '2026-01-01', @EndDate = '2026-12-31';

CREATE PROCEDURE sp_MonthlyRevenuevsTarget_2252
    @
AS
BEGIN   
    IF
    BEGIN
        THROW 50004, '', 1;
    END


--A5: Monthly Revenue Target Report
CREATE PROCEDURE sp_MonthlyRevenueTargetReport_2252
AS
BEGIN
    DECLARE @Target DECIMAL(18,2) = 500000.00;

    BEGIN TRY
        SELECT 
            -- Identifying the row type
            CASE 
                WHEN GROUPING(YEAR(p.PaymentDate)) = 1 THEN 'OVERALL SUMMARY'
                ELSE CAST(YEAR(p.PaymentDate) AS VARCHAR) + '-' + 
                     FORMAT(p.PaymentDate, 'MMMM') 
            END AS [Month-Year],

            SUM(p.AmountPaid) AS TotalRevenue,

            -- Status Logic
            CASE 
                WHEN GROUPING(YEAR(p.PaymentDate)) = 1 THEN '---'
                WHEN SUM(p.AmountPaid) >= @Target THEN 'YES'
                ELSE 'NO'
            END AS TargetMet,

            -- Surplus/Deficit Logic
            SUM(p.AmountPaid) - (CASE WHEN GROUPING(YEAR(p.PaymentDate)) = 1 THEN 0 ELSE @Target END) AS SurplusDeficit
            
        FROM VED_Payment_2252 p
        GROUP BY ROLLUP ((YEAR(p.PaymentDate), MONTH(p.PaymentDate), FORMAT(p.PaymentDate, 'MMMM')))
        -- Cleaning up partial rollups
        HAVING GROUPING(YEAR(p.PaymentDate)) = 1 
           OR (MONTH(p.PaymentDate) IS NOT NULL)
        ORDER BY GROUPING(YEAR(p.PaymentDate)), MIN(p.PaymentDate);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;

EXEC sp_MonthlyRevenueTargetReport_2252;

--TRIGGER

--B1)Prevent Double-Booking Trigger
CREATE TRIGGER trg_PreventDoubleBooking_2252
ON VED_Appointments_2252
AFTER INSERT, UPDATE
AS
BEGIN
    -- Avoid nested trigger issues
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM VED_Appointments_2252 a
        JOIN Inserted i ON a.DoctorID = i.DoctorID 
            AND a.AppointmentDate = i.AppointmentDate 
            AND a.AppointmentTime = i.AppointmentTime
            AND a.AppointmentID <> i.AppointmentID -- Don't compare a row to itself
        WHERE a.Status <> 'Cancelled' -- Cancelled appointments don't count as conflicts
    )
    BEGIN
        RAISERROR ('Conflict Detected: This doctor already has an appointment at the selected date and time.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

-- Step 2: Attempt to book the SAME doctor at the SAME time
BEGIN TRY
    INSERT INTO VED_Appointments_2252 (PatientID, DoctorID, AppointmentDate, AppointmentTime, Status)
    VALUES (2, 1, '2026-03-10', '09:30', 'Scheduled');
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS TriggerErrorMessage;
END CATCH

--B2)Automated Billing Trigger
CREATE TRIGGER trg_AutomateBilling_2252
ON VED_Appointments_2252
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Only proceed if Status was updated to 'Completed'
    IF EXISTS (SELECT 1 FROM Inserted i JOIN Deleted d ON i.AppointmentID = d.AppointmentID 
               WHERE i.Status = 'Completed' AND d.Status <> 'Completed')
    BEGIN
        INSERT INTO VED_Billing_2252 (
            AppointmentID, 
            ConsultationCharge, 
            MedicineCost, 
            LabCost, 
            InsuranceDiscount, 
            GST, 
            FinalAmount, 
            PaymentStatus
        )
        SELECT 
            i.AppointmentID,
            doc.ConsultationFee,
            ISNULL(meds.TotalMed, 0),
            ISNULL(labs.TotalLab, 0),
            -- Insurance Discount Calculation
            ( (doc.ConsultationFee + ISNULL(meds.TotalMed, 0) + ISNULL(labs.TotalLab, 0)) * (ISNULL(ins.CoveragePercentage, 0) / 100.0) ),
            -- GST (18%) on the amount AFTER insurance discount
            ( (doc.ConsultationFee + ISNULL(meds.TotalMed, 0) + ISNULL(labs.TotalLab, 0)) * 0.18 ),
            -- Final Calculation
            ( (doc.ConsultationFee + ISNULL(meds.TotalMed, 0) + ISNULL(labs.TotalLab, 0)) * 1.18 ) - 
            ( (doc.ConsultationFee + ISNULL(meds.TotalMed, 0) + ISNULL(labs.TotalLab, 0)) * (ISNULL(ins.CoveragePercentage, 0) / 100.0) ),
            'Unpaid'
        FROM Inserted i
        JOIN VED_Doctors_2252 doc ON i.DoctorID = doc.DoctorID
        LEFT JOIN VED_Insurance_2252 ins ON i.PatientID = ins.PatientID
        -- Subquery for Medicine Costs
        LEFT JOIN (
            SELECT r.AppointmentID, SUM(m.UnitPrice * p.Quantity) as TotalMed
            FROM VED_MedicalRecords_2252 r
            JOIN VED_Prescriptions_2252 p ON r.RecordID = p.RecordID
            JOIN VED_Medicines_2252 m ON p.MedicineID = m.MedicineID
            GROUP BY r.AppointmentID
        ) meds ON i.AppointmentID = meds.AppointmentID
        -- Subquery for Lab Costs
        LEFT JOIN (
            SELECT lo.AppointmentID, SUM(lt.BaseCost) as TotalLab
            FROM VED_LabOrders_2252 lo
            JOIN VED_LabTests_2252 lt ON lo.TestID = lt.TestID
            GROUP BY lo.AppointmentID
        ) labs ON i.AppointmentID = labs.AppointmentID
        WHERE i.Status = 'Completed';
    END
END;
GO

--Delete the existing manual bill
DELETE FROM VED_Payment_2252 WHERE BillID = (SELECT BillID FROM VED_Billing_2252 WHERE AppointmentID = 4);
DELETE FROM VED_Billing_2252 WHERE AppointmentID = 4;

-- Test: Complete an existing scheduled appointment
UPDATE VED_Appointments_2252 
SET Status = 'Completed' 
WHERE AppointmentID = 4;
SELECT * FROM VED_Appointments_2252;

-- Check if the bill was generated automatically
SELECT * FROM VED_Billing_2252 WHERE AppointmentID = 4;

--B3)Follow-up Reminder Trigger

CREATE TRIGGER trg_ScheduleFollowUp_2252
ON VED_MedicalRecords_2252
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Only fire if RequiresFollowUp is set to 1 (True)
    IF EXISTS (SELECT 1 FROM Inserted WHERE RequiresFollowUp = 1)
    BEGIN
        INSERT INTO VED_Appointments_2252 (
            PatientID, 
            DoctorID, 
            AppointmentDate, 
            AppointmentTime, 
            Status
        )
        SELECT 
            a.PatientID, 
            a.DoctorID, 
            DATEADD(day, 7, a.AppointmentDate), -- Suggest date 7 days from today
            a.AppointmentTime, 
            'Scheduled'
        FROM Inserted i
        JOIN VED_Appointments_2252 a ON i.AppointmentID = a.AppointmentID
        -- Prevent duplicate follow-ups if the record is updated multiple times
        WHERE NOT EXISTS (
            SELECT 1 FROM VED_Appointments_2252 next_a 
            WHERE next_a.PatientID = a.PatientID 
            AND next_a.AppointmentDate = DATEADD(day, 7, a.AppointmentDate)
        );

        PRINT 'System Alert: Follow-up appointment has been automatically drafted for 7 days from now.';
    END
END;
GO


-- Test: Add a medical record that requires a follow-up
INSERT INTO VED_MedicalRecords_2252 (AppointmentID, Diagnosis, TreatmentPlan, RequiresFollowUp)
VALUES (6, 'Chronic Back Pain', 'Physiotherapy sessions', 1);

-- Check if a new appointment was created for 7 days later
SELECT * FROM VED_Appointments_2252 WHERE PatientID = (SELECT PatientID FROM VED_Appointments_2252 WHERE AppointmentID = 6);

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

/* SECTION 04: SECURITY & ROLES */

-- 1. Create Restricted View for Billing Staff (Name & Insurance only)
CREATE VIEW vw_PatientInsuranceInfo_2252 AS
SELECT 
    p.PatientID, 
    p.FirstName, 
    p.LastName, 
    i.ProviderName, 
    i.CoveragePercentage, -- Using the column name from your previous tasks
    p.InsurancePolicyNo
FROM VED_Patients_2252 p
LEFT JOIN VED_Insurance_2252 i ON p.PatientID = i.PatientID;
GO

-- 2. Create the Database Roles
CREATE ROLE db_receptionist_2252;
CREATE ROLE db_doctor_2252;
CREATE ROLE db_lab_tech_2252;
CREATE ROLE db_billing_2252;
CREATE ROLE db_admin_2252;
GO

-- 3. db_receptionist permissions
-- Can manage patients and appointments, but nothing clinical or financial
GRANT SELECT, INSERT ON VED_Patients_2252 TO db_receptionist_2252;
GRANT SELECT, INSERT ON VED_Appointments_2252 TO db_receptionist_2252;
-- Explicitly deny clinical/financial (Best Practice)
DENY SELECT ON VED_Billing_2252 TO db_receptionist_2252;
DENY SELECT ON VED_MedicalRecords_2252 TO db_receptionist_2252;

-- 4. db_doctor permissions
-- Can see patients but only edit clinical records
GRANT SELECT ON VED_Patients_2252 TO db_doctor_2252;
GRANT SELECT ON VED_Appointments_2252 TO db_doctor_2252;
GRANT SELECT, INSERT, UPDATE ON VED_MedicalRecords_2252 TO db_doctor_2252;
GRANT SELECT, INSERT, UPDATE ON VED_Prescriptions_2252 TO db_doctor_2252;
GRANT SELECT, INSERT, UPDATE ON VED_LabOrders_2252 TO db_doctor_2252;
DENY SELECT ON VED_Billing_2252 TO db_doctor_2252;

-- 5. db_lab_tech permissions
-- Access to tests and orders; update ONLY specific result columns
GRANT SELECT ON VED_LabTests_2252 TO db_lab_tech_2252;
GRANT SELECT ON VED_LabOrders_2252 TO db_lab_tech_2252;
-- Column-level security for updating results
GRANT UPDATE (Result, isAbnormal) ON VED_LabOrders_2252 TO db_lab_tech_2252; 
DENY SELECT ON VED_Patients_2252 TO db_lab_tech_2252; -- No personal info access

-- 6. db_billing permissions
-- Can manage money and see the restricted view, not the full patient table
GRANT SELECT, INSERT, UPDATE ON VED_Billing_2252 TO db_billing_2252;
GRANT SELECT ON vw_PatientInsuranceInfo_2252 TO db_billing_2252; 
DENY SELECT ON VED_MedicalRecords_2252 TO db_billing_2252;
DENY SELECT ON VED_Prescriptions_2252 TO db_billing_2252;
DENY SELECT ON VED_Patients_2252 TO db_billing_2252; -- Use the view instead

-- 7. db_admin permissions
-- Admins usually get 'db_owner' which bypasses all DENY rules
EXEC sp_addrolemember 'db_owner', 'db_admin_2252';
GO
