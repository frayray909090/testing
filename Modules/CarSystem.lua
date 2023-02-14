local Siren = Import("Siren")

local CarContainer = workspace.CarContainer

local CarSystem = {
    CarInfo = {
        Sedan = {
            Health = 1000,
            Window = 25,
            Tires = 60
        },
        Squad = {
            Health = 1500,
            Window = 100,
            Tires = 75
        }
    },
    Cars = {},
    Destroy = function(self, Car)
        self.Cars[Car] = nil
    end,
    CarDamageHandler = function(Data)
        local Hit = Data.Hit
        local Gun = Data.Gun
        
        local GunStates = Gun and Gun:FindFirstChild("GunStates") and require(Gun.GunStates)
    
        if not Hit or not Gun then return end
        
        local Car, CarData = GetCarFromPart(Hit)

        if not CarData then return end
        CarData:Update(Hit, GunStates.Damage)
    end
}

for _, Car in next, CarContainer:GetChildren() do
    CarSystem.Cars[Car] = {
        Car = Car,
        Name = Car.Name,
        -- Window = CarSystem.CarInfo[Car.Name].Window,
        -- Tire = CarSystem.CarInfo[Car.Name].Tires,
        Health = {
            Base = CarSystem.CarInfo[Car.Name].Health,
            Windshield = CarSystem.CarInfo[Car.Name].Window,
            RearWindow = CarSystem.CarInfo[Car.Name].Window,
            LeftWindow = CarSystem.CarInfo[Car.Name].Window,
            RightWindow = CarSystem.CarInfo[Car.Name].Window,
            LFTire = CarSystem.CarInfo[Car.Name].Tires,
            RFTire = CarSystem.CarInfo[Car.Name].Tires,
            LBTire = CarSystem.CarInfo[Car.Name].Tires,
            RBTire = CarSystem.CarInfo[Car.Name].Tires,
        },
        DisableWelds = function(self, Part)
            for _, Weld in next, self.Car:GetDescendants() do
                pcall(function()
                    if Weld:IsA("JointInstance") and (Weld.Part0 == Part or Weld.Part1 == Part) then
                        -- print(Weld)
                        Siren:Disable(Weld)
                    end
                end)
            end
        end,
        IdentifyPart = function(self, Part)
            local Main = self.Car.Body.Main

            local Angle = math.deg(math.acos(Main.CFrame.LookVector.unit:Dot((Part.Position-Main.Position).unit)))
            local Offset = (Angle - 90)
            
            Offset = math.ceil(Offset > 0 and Offset < 1 and Offset * 1000 or Offset)
            
            if Offset == -20 then
                return "LFTire"
            end
            if Offset == -78 then
                return "LBTire"
            end
            if Offset == 21 then
                return "RFTire"
            end
            if Offset == 79 then
                return "RBTire"
            end
            if Part.Transparency > 0 then
                if Offset == 33 or Offset == 44 then
                    return "Windshield", {33, 44}
                end
                if Offset == -36 then
                    return "LeftWindow"
                end
                if Offset == 37 then
                    return "RightWindow"
                end
                if Offset == 124 or Offset == 123 then
                    return "RearWindow", {124, 123}
                end
            end

            return "Base"
        end,
        GetPartFromAngle = function(self, Angle)
            local Main = self.Car.Body.Main
            for _, Part in next, self.Car:GetDescendants() do
                if Part:IsA("BasePart") then
                    local Offset = (math.deg(math.acos(Main.CFrame.LookVector.unit:Dot((Part.Position-Main.Position).unit))) - 90)
                    Offset = math.ceil(Offset > 0 and Offset < 1 and Offset * 1000 or Offset)
                    if Part.Transparency > 0 then
                        if Offset == Angle then return Part end
                    end
                end
            end
        end,
        Update = function(self, Hit, Damage)
            local Identifier, Angles = self:IdentifyPart(Hit)
            local Health = self.Health[Identifier]

            Health = Health - Damage

            print("Car hit at", Identifier, "for", Damage, "damage leaving ", Health, "amount of health")

            self.Health[Identifier] = Health

            if Health <= 0 then
                self.Health[Identifier] = math.huge
                if Identifier ~= "Base" then
                    if Identifier == "Windshield" or Identifier == "RearWindow" then
                        for _, Angle in next, Angles do
                            local Part = self:GetPartFromAngle(Angle)
                            self:DisableWelds(Part)
                        end
                    else
                        self:DisableWelds(Hit)
                    end
                    return
                end
                self:Destroy()
            end
        end,
        Destroy = function(self)
            for _, Seat in next, self.Car.Body:GetChildren() do
                if Seat:IsA("Seat") then
                    self:DisableWelds(self.Car.Body.Seat)
                end
            end
            CarSystem:Destroy(self.Car)
        end
    }
end

CarContainer.ChildAdded:Connect(function(Car)
    print(Car.Name, "Spawned")
    CarSystem.Cars[Car] = {
        Car = Car,
        Name = Car.Name,
        Health = {
            Base = CarSystem.CarInfo[Car.Name].Health,
            Windshield = CarSystem.CarInfo[Car.Name].Window,
            RearWindow = CarSystem.CarInfo[Car.Name].Window,
            LeftWindow = CarSystem.CarInfo[Car.Name].Window,
            RightWindow = CarSystem.CarInfo[Car.Name].Window,
            LFTire = CarSystem.CarInfo[Car.Name].Tires,
            RFTire = CarSystem.CarInfo[Car.Name].Tires,
            LBTire = CarSystem.CarInfo[Car.Name].Tires,
            RBTire = CarSystem.CarInfo[Car.Name].Tires,
        },
        DisableWelds = function(self, Part)
            for _, Weld in next, self.Car:GetDescendants() do
                pcall(function()
                    if Weld:IsA("JointInstance") and (Weld.Part0 == Part or Weld.Part1 == Part) then
                        Siren:Disable(Weld)
                    end
                end)
            end
        end,
        IdentifyPart = function(self, Part)
            local Main = self.Car.Body.Main

            local Angle = math.deg(math.acos(Main.CFrame.LookVector.unit:Dot((Part.Position-Main.Position).unit)))
            local Offset = (Angle - 90)
                
            Offset = math.ceil(Offset > 0 and Offset < 1 and Offset * 1000 or Offset)

            if Offset == -20 then
                return "LFTire"
            end
            if Offset == -78 then
                return "LBTire"
            end
            if Offset == 21 then
                return "RFTire"
            end
            if Offset == 79 then
                return "RBTire"
            end
            if Part.Transparency > 0 then
                if Offset == 33 or Offset == 44 then
                    return "Windshield", {33, 44}
                end
                if Offset == -36 then
                    return "LeftWindow"
                end
                if Offset == 37 then
                    return "RightWindow"
                end
                if Offset == 124 or Offset == 123 then
                    return "RearWindow", {124, 123}
                end
            end

            return "Base"
        end,
        GetPartFromAngle = function(self, Angle)
            local Main = self.Car.Body.Main
            for _, Part in next, self.Car:GetDescendants() do
                if Part:IsA("BasePart") then
                    local Offset = (math.deg(math.acos(Main.CFrame.LookVector.unit:Dot((Part.Position-Main.Position).unit))) - 90)
                    Offset = math.ceil(Offset > 0 and Offset < 1 and Offset * 1000 or Offset)
                    if Part.Transparency > 0 then
                        if Offset == Angle then return Part end
                    end
                end
            end
        end,
        Update = function(self, Hit, Damage)
            local Identifier, Angles = self:IdentifyPart(Hit)
            local Health = self.Health[Identifier]

            Health = Health - Damage

            print("Car hit at", Identifier, "for", Damage, "damage leaving ", Health, "amount of health")

            self.Health[Identifier] = Health

            if Health <= 0 then
                self.Health[Identifier] = math.huge
                if Identifier ~= "Base" then
                    if Identifier == "Windshield" or Identifier == "RearWindow" then
                        for _, Angle in next, Angles do
                            local Part = self:GetPartFromAngle(Angle)
                            self:DisableWelds(Part)
                        end
                    else
                        self:DisableWelds(Hit)
                    end
                    return
                end
                self:Destroy()
            end
        end,
        Destroy = function(self)
            for _, Seat in next, self.Car.Body:GetChildren() do
                if Seat:IsA("Seat") then
                    self:DisableWelds(self.Car.Body.Seat)
                end
            end
            CarSystem:Destroy(self.Car)
        end
    }
end)

function GetCarFromPart(part)
    for Car, Data in next, CarSystem.Cars do
        if part:IsDescendantOf(Car) then
            return Car, Data
        end
    end
end

return CarSystem
