import styles from "./ScreenHeader.module.css";

interface ScreenHeaderProps {
  title: string;
  subtitle?: string;
  onBack?: () => void;
}

export function ScreenHeader({ title, subtitle, onBack }: ScreenHeaderProps) {
  return (
    <div className={styles.wrap}>
      {onBack ? (
        <button type="button" className={styles.back} onClick={onBack} aria-label="Volver">
          ‹
        </button>
      ) : null}
      <div>
        <h1 className={styles.title}>{title}</h1>
        {subtitle ? <p className={styles.subtitle}>{subtitle}</p> : null}
      </div>
    </div>
  );
}
