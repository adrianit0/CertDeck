"use client";

import { BookOpen, RotateCw, BarChart3, User } from "lucide-react";

interface NavigationProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
}

export default function Navigation({ activeTab, onTabChange }: NavigationProps) {
  const tabs = [
    { id: "cursos", name: "Cursos", icon: BookOpen },
    { id: "repasos", name: "Repasos", icon: RotateCw },
    { id: "progresos", name: "Progresos", icon: BarChart3 },
    { id: "perfil", name: "Perfil", icon: User },
  ];

  return (
    <nav className="absolute bottom-0 left-0 right-0 h-20 bg-white border-t border-slate-100 shadow-[0_-5px_15px_-3px_rgba(0,0,0,0.03)] z-40 px-4">
      <div className="max-w-md mx-auto h-full flex justify-around items-center">
        {tabs.map((tab) => {
          const IconComponent = tab.icon;
          const isActive = activeTab === tab.id;

          return (
            <button
              key={tab.id}
              id={`nav-btn-${tab.id}`}
              onClick={() => onTabChange(tab.id)}
              className={`flex flex-col items-center justify-center w-16 h-16 rounded-2xl transition-all duration-300 ${
                isActive ? "text-brand-primary font-semibold" : "text-slate-400 hover:text-slate-600"
              }`}
              aria-label={tab.name}
            >
              <div
                className={`p-1.5 rounded-xl transition-all ${
                  isActive ? "bg-brand-primary-light scale-110" : "bg-transparent"
                }`}
              >
                <IconComponent className="w-5.5 h-5.5 stroke-[2.2]" />
              </div>
              <span className="text-[10px] mt-1 tracking-wide">{tab.name}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}
