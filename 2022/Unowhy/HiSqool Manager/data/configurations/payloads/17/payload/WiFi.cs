using System;
using System.Threading;
using System.ComponentModel;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public class WiFi
{ 
    public static unsafe void Connect(string profile)
    {
        int actual; IntPtr handle;
        var r = WlanOpenHandle(2, IntPtr.Zero, out actual, out handle);
        if (r != 0) throw new Win32Exception(r);

        void* pointer;
        r = WlanEnumInterfaces(handle, IntPtr.Zero, out pointer);
        var list = (InterfaceList*)pointer;
        if (r != 0) throw new Win32Exception(r);

        fixed (char* pProfile = profile)
        {
            var parameters = new ConnectionParameters()
            {
                Mode = ConnectionMode.StoredProfile,
                Type = ConnectionType.Any,
                Profile = pProfile
            };

            for (var i = 0; i < list->Count; i++)
            {
                var item = (&list->First)[i];

                if (!GetNetworks(handle, item.Id).Contains(profile))
                    continue; // Skip

                if (WlanConnect(handle, &item.Id, &parameters, IntPtr.Zero) == 0)
                    break; // Stop on first success
            }
        }

        WlanFreeMemory(list);

        r = WlanCloseHandle(handle, IntPtr.Zero);
        if (r != 0) throw new Win32Exception(r);
    }

    public static unsafe List<string> GetNetworks(IntPtr client, Guid id)
    {
        try
        {
            WlanScan(client, &id, null, IntPtr.Zero, IntPtr.Zero);
            Thread.Sleep(4000); // WlanScan is async, Windows logo requires less that 4 seconds

            void* pointer;
            var r = WlanGetAvailableNetworkList(client, &id, DiscoveryOptions.IncludeHiddenManual, IntPtr.Zero, out pointer);
            var list = (NetworkList*)pointer;
            if (r != 0) throw new Win32Exception(r);

            try
            {
                var result = new List<string>(list->Count);

                for (var i = 0; i < list->Count; i++)
                {
                    var item = (&list->First)[i];
                    var ssid = item.Ssid.ToString();
                    if (ssid.Length == 0)
                        continue;

                    result.Add(ssid);
                }

                return result;
            }
            finally
            {
                WlanFreeMemory(list);
            }
        }
        catch
        {
            // On privacy error
            return new List<string>();
        }
    }

    [DllImport("wlanapi.dll")]
    public static extern int WlanOpenHandle(int request, IntPtr reserved, out int actual, out IntPtr handle);
    [DllImport("wlanapi.dll")]
    public static extern int WlanCloseHandle(IntPtr handle, IntPtr reserved);
    [DllImport("wlanapi.dll")]
    public static extern unsafe int WlanEnumInterfaces(IntPtr handle, IntPtr reserved, out void* list);
    [DllImport("wlanapi.dll")]
    public static extern unsafe int WlanGetAvailableNetworkList(IntPtr handle, Guid* id, DiscoveryOptions options, IntPtr reserved, out void* list);
    [DllImport("wlanapi.dll")]
    public static extern unsafe int WlanConnect(IntPtr handle, Guid* id, ConnectionParameters* parameters, IntPtr reserved);
    [DllImport("wlanapi.dll")]
    public static extern unsafe void WlanFreeMemory(void* result);
    [DllImport("wlanapi.dll")]
    public static extern unsafe int WlanScan(IntPtr handle, Guid* id, Ssid* pDot11Ssid, IntPtr data, IntPtr reserved);

    [StructLayout(LayoutKind.Sequential)]
    public struct NetworkList
    {
        public int Count;
        public int Index;
        public Network First;
    }

    [StructLayout(LayoutKind.Sequential)]
    public unsafe struct Ssid
    {
        public uint Length;
        public fixed byte Profile[32];

        public override string ToString()
        {
            fixed (byte* p = Profile)
            {
                return Marshal.PtrToStringAnsi(new IntPtr(p), (int)Length);
            }
        }
    }

    public enum SsidType
    {
        Infrastructure = 1,
        AdHoc = 2,
    }

    public enum NetworkConnectivity
    {
        Disabled = 0,
        Enabled = 1
    }

    public enum PhyTypesMode
    {
        Short = 0,
        Long = 1
    }

    public enum NetworkConnectivityIssue
    {
        None = 0
    }

    public enum NetworkSecutity
    {
        Disabled = 0,
        Enabled = 1
    }

    public enum AuthenticationAlgorithm
    {
        Open = 1,
        SharedKey = 2,
        Wpa = 3,
        WpaPsk = 4,
        WpaNone = 5,
        Rsna = 6,
        RsnaPsk = 7,
        Wpa3 = 8,
        Wpa3Sae = 9,
        Owe = 10,
        Wpa3Ent = 11
    }

    public enum CipherAlgorithm
    {
        None = 0,
        Wep40 = 1,
        Tkip = 2,
        Ccmp = 4,
        Wep104 = 5,
        UseGroup = 0x100,
        Wep = 0x101
    }

    [Flags]
    public enum NetworkStatus
    {
        Connected = 1,
        HasProfile = 2
    }

    // _WLAN_AVAILABLE_NETWORK
    [StructLayout(LayoutKind.Sequential)]
    public unsafe struct Network
    {
        public fixed char Profile[256];
        public Ssid Ssid;
        public SsidType Type;
        public uint CountSsid;
        public NetworkConnectivity Connectivity;
        public NetworkConnectivityIssue Issue;
        public uint CountPhyTypes;
        public fixed int PhyTypes[8];
        public PhyTypesMode PhyTypesMode;
        public uint Quality;
        public NetworkSecutity Security;
        public AuthenticationAlgorithm AuthenticationAlgorithm;
        public CipherAlgorithm CipherAlgorithm;
        public NetworkStatus Flags;
        public int Reserved;

        public override string ToString()
        {
            fixed (char* p = Profile)
            {
                return new string(p);
            }
        }
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct InterfaceList
    {
        public int Count;
        public int Index;
        public Interface First;
    }

    [StructLayout(LayoutKind.Sequential)]
    public unsafe struct Interface
    {
        public Guid Id;
        public fixed char Description[256];
        public InterfaceState State;
    }

    public enum InterfaceState
    {
        NotReady,
        Connected,
        AdHoc,
        Disconnecting,
        Disconnected,
        Associating,
        Discovering,
        Authenticating
    }

    [StructLayout(LayoutKind.Sequential)]
    public unsafe struct ConnectionParameters
    {
        public ConnectionMode Mode;
        public char* Profile;
        public IntPtr Reserved1;
        public IntPtr Reserved2;
        public ConnectionType Type;
        public ConnectionOptions Options;
    }

    public enum ConnectionMode
    {
        StoredProfile,
        TemporaryProfile,
        DiscoverySecure,
        DiscoveryUnsecure,
        Auto
    }

    public enum ConnectionType
    {
        Infrastructure = 1,
        AdHoc = 2,
        Any = 3
    }

    [Flags]
    public enum ConnectionOptions
    {
        None = 0,
        Hidden = 1
    }

    [Flags]
    public enum DiscoveryOptions
    {
        None = 0,
        IncludeHiddenAdHoc = 1,
        IncludeHiddenManual = 2
    }
}